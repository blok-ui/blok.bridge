package blok.bridge.server;

import kit.file.*;
import mime.Mime;
import kit.http.*;
import kit.http.Handler;

using DateTools;
using StringTools;
using haxe.io.Path;

typedef StaticExpiry = Null<Int>;

// 	Mostly taken from https://github.com/haxetink/tink_http_middleware/blob/master/src/tink/http/middleware/Static.hx
// 	with some changes for Blok.
class StaticFileMiddleware implements Middleware {
	public final config:Config;
	public final logger:Logger;
	public final output:OutputDirectory;
	public final expiry:StaticExpiry;

	public function new(config, logger, output, expiry) {
		this.config = config;
		this.logger = logger;
		this.output = output;
		this.expiry = expiry;
	}

	public function apply(handler:Handler):Handler {
		return request -> {
			var path = request.url.path;
			var prefix = config.assetsDirectory;

			if (request.method != Get || !path.startsWith(prefix)) {
				return handler.process(request);
			}

			logger.log(Info, 'Static file: ${path}');

			var decodePath = try path.urlDecode() catch (e) return handler.process(request);

			// decline considering anything with null bytes in this middleware
			if (decodePath.indexOf('\x00') > -1) return handler.process(request);

			return output
				.file(decodePath)
				.pipe(partial(request, _, Mime.lookup(decodePath)))
				.recover(_ -> handler.process(request));
		}
	}

	function partial(req:Request, file:File, contentType:String):Task<Response> {
		return file.getMeta().next(meta -> file.readBytes().next(source -> {
			var headers:Headers = [
				new HeaderField('Accept-Ranges', 'bytes'),
				new HeaderField('Vary', 'Accept-Encoding'),
				new HeaderField('Last-Modified', meta.updated.toString()),
				new HeaderField('Content-Type', contentType),
				new HeaderField('Content-Disposition', 'inline; filename="${meta.name}"'),
			];

			if (expiry != null) {
				headers = headers.with(
					new HeaderField('Expires', Date.now().delta(expiry * 1000).toString()),
					new HeaderField('Cache-Control', 'max-age=${expiry}')
				);
			}

			// // @todo: We'll have to do this when we have actual streams.
			// switch req.headers.find('range') {
			//   case Some(v):
			//     switch (v:String).split('=') {
			//       case ['bytes', range]:
			//         function res(pos:Int, len:Int) {
			//           return new Response(
			//             new ResponseHeader(206, 'Partial Content', headers.concat([
			//               new HeaderField('Content-Range', 'bytes $pos-${pos + len - 1}/${file.meta.size}'),
			//               new HeaderField('Content-Length', len),
			//             ])),
			//             source.skip(pos).limit(len)
			//           );
			//         }

			//         switch range.split('-') {
			//           case ['', Std.parseInt(_) => len]:
			//             return res(file.meta.size - len, len);
			//           case [Std.parseInt(_) => pos, '']:
			//             return res(pos, file.meta.size - pos);
			//           case [Std.parseInt(_) => pos, Std.parseInt(_) => end]:
			//             return res(pos, end - pos + 1);
			//           default:
			//             // unrecognized byte-range-set (should probably return an error)
			//         }
			//       default:
			//         // unrecognized bytes-unit (should probably return an error)
			//     }
			//   case None(_):
			// }

			return new Response(
				OK,
				headers.with(new HeaderField(ContentLength, meta.size)),
				source
			);
		}));
	}
}
