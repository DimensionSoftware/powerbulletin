define = window?define or require(\amdefine) module
require, exports, module <- define

require! { $R: \reactivejs }

# globals we want at beginning of application
@r-socket = $R.state!
@r-user = $R.state!

@
# vim:fdm=marker
