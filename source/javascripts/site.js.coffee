#= require lib/request_animation_frame
#= require lib/scroll_animation
#= require lib/jquery.autosize

$body = $(document.body)

#-----------------------------------------------------------------------------
# Autosize
#-----------------------------------------------------------------------------

$body.find('textarea.autosize').autosize(append: '\n')

#-----------------------------------------------------------------------------
# Run scroll animations
#-----------------------------------------------------------------------------

ScrollAnimation.start()
