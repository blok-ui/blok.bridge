# Islands and Context

Islands should be able to serialize context and share it with other islands! Here's an idea of how to do it:

First off, Islands can only use serializable Context, the same as all other objects that get passed to them. The one difference is that we want to share Contexts between Islands if needed, so we will create a hash from their serialized props (plus class name) to act as an identifier.
