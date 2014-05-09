
0.0.1 / 2014-02-05 
==================

  * added crop preview to PhotoCropper
  * fix: .bottom -> .post-bottom (colliding w/ jCrop style)
  * latest 404/50x page
  * added bin/build-procs and then some
  * fix: lazy-load iris on demand
  * comment out iris for now
  * cleaned out CKEditor
  * misc. ui
  * merged
  * Merge branch 'editor'
  * PostDrawer reply/editing/creating all working
  * lazy loading iris later seems to work
  * fix: PostDrawer replies work initially
  * fix: call layout-on-personalize
  * editing now updating on client after save
  * fix: saving post titles again
  * Merge branch 'master' into editor
  * fleshing out theme admin ui
  * misc. ui for search and keyboard
  * merged, like b00m
  * Merge branch 'master' into editor
  * reorder color vars to be consistent with admin order
  * added a place to store color theme presets
  * forgot to add input for light_text
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * FIXME: need jquery.ui.widget for iris to work
  * basic admin ui for color themes
  * installed deep-equal
  * rebuild jade on first start
  * fix: hide PostDrawer on moderation mutant
  * fix: crash
  * design *b0mb*
  * fix: uncensor/censor personalize
  * Merge remote-tracking branch 'origin/master' into editor
  * post editing working!
  * fix: hide PostDrawer on moderation mutant
  * fix: crash
  * write out default color theme on site creation
  * fix /ajax/sites-and-memberships (forgot to check in?)
  * db.sites.save-color-theme(site, cb)
  * provide site-id to stylus route
  * fs migration for adding default color-scheme.styl for all existing sites
  * load models into migrate script
  * assume public/sites/:id/color-theme.styl exists and import it
  * added a way to customize render-css function
  * design *b0mb*
  * PostDrawer/Editor WIP
  * fix: uncensor/censor personalize
  * Merge branch 'master' into editor
  * Merge branch 'master' into prod
  * fix: really capture these
  * fix: moved #auth to bottom
  * Merge remote-tracking branch 'origin/master' into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui tweaks
  * Merge remote-tracking branch 'origin/master' into editor
  * working toward editing posts
  * set notice when initially loading conversations
  * fixed db.messages.mark-all-read
  * Merge branch 'master' into editor
  * make thread list's post count take moderations into account
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: firefox ui bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * removed console.logs
  * ^C restart PB faster
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes: various MiniSiteList membership issues
  * be careful not to parse-int something that could return NaN
  * Merge branch 'master' into editor
  * latest spritemap
  * misc. fixes & improvements before adding editing capabilities to PostDrawer/Editor
  * Merge branch 'master' into editor
  * latest spritemap w/ carved up Edit icon
  * fix: io-server crash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make last post selection in forum-summary aware of moderations
  * make forum-summary counts reflect moderations
  * post edit wip
  * Merge remote-tracking branch 'origin/master' into editor
  * fixes: moderation included w/ surf + ui alignment
  * added ability to uncensory + ui
  * dropping a design bomb on the ui
  * applied new sprites to ui
  * carved out all sprites
  * fixes: misc. ui bugs
  * admin++
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added latest spritemap from eMkel
  * added timeout const; removed default param value
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add a class to body if forum is in linear (no comment) mode
  * fix: show moderations when no content
  * faster & smoother menu closing
  * deal with urls w/ hostname but no trailing slash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check to see if socket is really ready
  * Pro Verbiage
  * fix: crash
  * fix: crash if bad parent_id
  * fixeses: drawer & social alignment
  * added thread-mode and ability to Create Thread (via button)
  * Pro Verbiage
  * fix: crash
  * ability to create threads on Forum Homepages using PostDrawer
  * comments & Editor working together
  * fix: crash if bad parent_id
  * Merge branch 'master' into editor
  * added watch & restart for pb-rt in development
  * fix: posting on profile page shows up
  * upgraded socket.io, announce & client
  * fix: crash on homepage static
  * adding title to PostDrawer
  * Merge branch 'master' into editor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui ++
  * fix: crash when no moderations
  * MainMenu and Tool menu close on selection/click
  * merged.
  * fixes: various ui tweaks for multi-use consistency
  * fix: ability to post from <form>'less PostDrawer
  * tried to add xbbcode stylesheet
  * use pagedown and xbbcode together
  * split jquery-regex out into own file
  * fix crash on /
  * Merge branch 'master' into editor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * moderations show only when exist
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added xbbcode parser and adapted it to work w/ amdefine
  * on-ready, ask socket.io who's online-now
  * fix typo
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * guard against duplicate messages showing up
  * fix: photocropper resizes on img load
  * check if item exists
  * aligned :'s
  * link to forum-level moderation log
  * fix: edit signature working
  * merged.
  * moderation page back online
  * fix: sig crashes
  * Merge branch 'master' into editor
  * misc. chat ui
  * ./bin/develop loop & grunt restarts faster
  * resize with css only
  * Merge remote-tracking branch 'origin/master' into editor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * no longer forward port 80 on vm
  * update time data attributes too
  * update thread title and username on thread create
  * increment thread and post counts in MenuSummary
  * explicitly require prelude-ls in shared-helpers
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge remote-tracking branch 'origin/master' into prod
  * PostDrawer resize WIP
  * fix: render socket.io'd comments again
  * Merge remote-tracking branch 'origin/master' into editor
  * fix: less forum spacing
  * (no)index & (no)follow toggle w/ private site
  * added change-case & title-case'ing titles
  * Merge remote-tracking branch 'origin/master' into editor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check if name already exists before trying to register
  * added robots.txt
  * fix: misc ui chat bugs @bao
  * only include minutes for time intervals < 1hr.
  * fix: replace chat list on every init
  * fix: multiple postdowns allowed in dom
  * fix: replace chat list on every init
  * only include minutes for time intervals < 1hr.
  * fix: resize in the right spot with pager or not
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' into prod
  * added keywords back to layout (SEO++)
  * fixes: misc. ui
  * PostDrawer & Editor WIP
  * added keywords back to layout (SEO++)
  * fixes: misc. ui
  * Merge remote-tracking branch 'origin/master' into editor
  * ui++
  * fix: crash on ridiculously slow networks that timeout
  * fix: only show sub MenuSummary when exists
  * only show Chats menu if previous conversations
  * fix: call r-socket after ready
  * added site-id to alias.photo path
  * ban-all-domains was on global already
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' into prod
  * no max-height; no float; max-width 100%
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge remote-tracking branch 'origin/master' into prod
  * Merge branch 'master' into editor
  * ui *b0mb*
  * attempting to handle big images, needs more work w/ fancybox, etc...
  * latest 404/50x pages
  * merged.
  * able to post with new postdown editor!
  * fix: resize properly guards
  * Merge branch 'master' into editor
  * fix: don't crash if site_id blank
  * fixes: misc. ui bugs
  * refreshed 404/50x pages
  * fix: don't crash if forum & user id unspecified
  * frontend for saving to server
  * PostDrawer (footer) resizes
  * Merge remote-tracking branch 'origin/master' into editor
  * old jsdom stuff which went away after upgrading
  * use jsdom on the server-side to correctly do url embedding after pagdown does its transformations
  * upgraded jsdom
  * Merge branch 'master' into editor
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' into prod
  * added PostDrawer.styl
  * wip
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * fix: always return latest sig
  * AdminUpgrade verbiage & ui
  * AdminUpgrade verbiage & ui
  * added Editor to PostDrawer
  * refactor: Editor is now generic
  * fix: always return latest sig
  * misc. ui
  * admin domain++
  * fix: crash when no config
  * MenuSummary++
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' into prod
  * fix chat style in firefox
  * call h.ban-all-domains when toggling sticky and locked
  * moved ban-all-domains(site-id) to server-helpers
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' into prod
  * don't display anything if menuSummary.length is 0
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' into prod
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added classes to tr "item-#{item.form.dialog}"
  * fix: hide details (dashes) when no content
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * show most recently active thread title instead of last post body
  * adapted code to use revised forum-summary from pb-models
  * revamped pb-models.forum-summary
  * upgraded bbcode
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Revert "fix: capitalize all tooltips"
  * Revert "fix: letter-spacing & text-transform making text wrap"
  * fix: letter-spacing & text-transform making text wrap
  * Revert "fix: capitalize all tooltips"
  * fix: capitalize all tooltips
  * Revert "background color is no-longer tinted"
  * added post drawer
  * normalized MenuSummary horizontal height & tamed ui
  * background color is no-longer tinted
  * added dates & defaults to MenuSummary
  * cleanup
  * new tabular homepage
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made format.ls server-only
  * made format.ls server-only
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: guard custom_domain subscription
  * fixed cvars issue in once-admin
  * fixed panel removal selector
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: using click again
  * force initial transition to have 0 delay
  * chat-panel transition
  * added set-profile to list of required fns
  * fix: crash for imported form data without a .form
  * top-right tool menu animates less
  * adds ability to add custom domains in /admin
  * added oneliner thread list for left-content
  * cleanup locked toggle
  * remove console.log from push-state wrapper
  * added profile link and then some to Chat Panel
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wrap around History.push-state to work around bug
  * cleanup dirty, dirty hack alert
  * fix: always summarize, even when surfing
  * disabled pins (for now)
  * latest menu summary and then some
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove console.log
  * optional animation for scroll-to-latest
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * when removing, be aware that some panels don't have icons
  * glosss buttons back!
  * added data-time attribute to chat messages
  * added template for chat list item
  * ability to select past chats
  * almost have chat list working
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: decorate crash & playing with new data
  * 404++
  * added chat-past message to load list of past chats
  * cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sort by most recent msg and add participants to db.conversations.past(cid, cb)
  * using new forum summary query for thread & post count
  * added ChatList component (currently empty)
  * fix crash when marking message; wrong user id
  * fix crash when forum-ids is empty; may need more work
  * message automatically marked read for sender of message
  * mark all read on open
  * increment notice when chat panel is minimized
  * (404 & 50x)++
  * adding stats. to homepage & forum homepage views
  * animations (needed fluidity) on 404 & 50x pages
  * Revert "upgraded fluidity"
  * upgraded fluidity
  * switch between prod/dev for 404 & 50x
  * new 404 & 50x pages
  * fix: google font is back
  * remove menu from surfing data
  * fix: main menu working again
  * when disconnected add a disconnected class to html tag
  * load old messages when scrolling back
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * trying to load previous messages
  * menu summary on top-level at given depth
  * frontend for unread messages
  * filter out conversations with no unread messages
  * chat-mark-all-read
  * added an unread class to unread messages
  * add data-mid to li
  * chat-mark-read, chat-mark-read-since
  * style for messages li
  * Chat & Admin UI
  * load initial messages via socket.io instead of xhr
  * initial chat notices
  * cleanup
  * latest jade
  * fix: all templates work w/ latest jade!
  * in anticipation of upgrading jade
  * fix: "input" has become a parse error in latest stylus?
  * upgraded stylus
  * fix: really initially scroll to bottom
  * properly close existing chats and be able to reopen them again
  * @scroll-to-latest
  * changed original should-scroll to near-bottom
  * scroll-to-latest and take image loading into consideration too
  * fix: ui properly collapses with removal
  * + mark read since
  * added first_unread_message_id to db.conversations.unread-summary-by-user
  * panels can be removed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * load initial messages
  * removed console.logs
  * fix: scrolled menu working
  * fix: improved clickable top-right corner
  * fix: clean up ParallaxButton style & don't move SiteRegister when clicking Create
  * fix: buttons always clickable and then some
  * icons & online in full-force
  * resolved.
  * socket.emit 'ready'
  * 'fixed' globals and fixed ChatPanel.add-conversation
  * properly eat returns & better handle key input
  * fix: really scroll to bottom
  * Chat++
  * fix: hoping to improve background sticking around issue
  * fix: use window.user if no local user
  * space out chat avatars
  * check for window's existence
  * amdefine for shared/format.ls
  * trying to setup reactive vars for chat on-personalize
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest chat ui
  * add list of participants to unread message summary
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * chat-unread is for finding out what chats have unread messages
  * cleanup Chat.*
  * fix: lazy-load autosize
  * remove stray console.warn
  * sneak in code to upconvert old messages without .html
  * use messages.html field instead of messages.body
  * moved formatting code out of server-helpers into own module
  * added messages.html for prerendered version of chat message
  * left/right alternation
  * removed unused experimental db code
  * oops, +Homepage.styl
  * *bomb*
  * seo++
  * Chat++
  * fixes: a few menu items are missing forms
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * run shared-helpers.add-dates on pb-model fns
  * recursing for MenuSummary
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: should be run last, might help w/ background lingering
  * added descriptions to menu items
  * hide post creation ui when thread or forum is locked
  * add locked class to body when thread or current forum is locked
  * upgraded cherio
  * cleanup forum description field
  * what was chat-server.send is now db.messages.send
  * focus after .show() finishes
  * add alias info of sender to message so recipients can show photo
  * remove app/chat.ls
  * remove debugging noise
  * focus textarea on open
  * messages are moving back and forth
  * fix: scroll to top on homepage mutant
  * fix: always remove spin class
  * fix: use destructured
  * Buy++ & misc. frontend
  * MenuSummary tracking active menu id & rendering!
  * increase clickable region for drop-down
  * Posts per Page -> Replies per Page
  * better distribution of cache-domains
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui
  * initial setup on MenuSummary & Pins for Homepage
  * don't make locked marker look clickable for non-admins
  * style for locked threads for non-admin users
  * forums now have their own posts-per-page setting
  * fix: discard event more selectively
  * Shining the shiny and more polish
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: prune background-color div, too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * thread locking ui for admins
  * fix: notes offset, etc...
  * only allow menu item to move after save
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * consolidated admin/domains into admin/general
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * setup thread nav controls on-load
  * cleanup
  * allow non admins to edit posts
  * made db.posts.toggle-locked consistent w/ toggle-sticky
  * route for thread stickiness toggle
  * move click handler for thread sticky toggle
  * code for showing/hiding thread stickiness admin ui
  * added markup and style for sticky toggle
  * fix: discard textarea click
  * added menu to repl
  * tooltip++
  * click to hold open admin menus
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: race condition should be fixed (no more yield)
  * misc. frontend verbiage & focusing
  * auto-save only checkboxes with .save class & only stylize .stylish checkboxes
  * tooltips now keyed to their id
  * added some padding to the bottom of ul.threads
  * delete should delete
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only look up user_id once
  * delete pages and forums by just using their id
  * fix: handle error when deleting
  * fix: rids horizontal scrollbar
  * added a helper method for adding new chat panels
  * Merge branch 'master' into chat
  * added link to past chat list / doesn't do anything yet
  * added a sticky class to sticky threads in left thread list
  * always allow menu item to move (even if unsaved)
  * fix: only show admin switcher when multiple sites
  * autovivify chat-panels as needed when new messages come in
  * this method must've disappeared during a merge
  * grab chat id via socket.io
  * removed deprecated comment
  * let ChatPanel figure out where the message goes
  * clear-stale-redis-data(redis-client, cb)
  * active thread arrow++
  * active arrow++
  * every ./Component is now a ./PBComponent
  * Buy tooltip++
  * fix: runtime error, needed to specify parents
  * fix: subscription crash
  * Single Homepage PBComponent for Mutant
  * + PBComponent
  * Component cleans up DOM
  * merged
  * chat-message handler (server-side)
  * focus & select
  * removed debugging noise from local login flow
  * thought db.forums.summary was more appropriate here
  * constrain announce to site.id room
  * colors...
  * hack to allow saving of top post
  * editing of posts less crashy, but it still doesn't quite work for first post of thread (need title separate from body)
  * added user_name and user_photo to result set
  * inital wip for new homepage
  * run time updater on every surf, too
  * socket.emit 'ping' on every surf
  * added ping to tickle alias.last_activity
  * don't crash
  * another temp fix
  * fix: crash (this is temp)
  * Merge branch 'master' into chat
  * added limit param to db.{sites,forums}.summary
  * resolved conflicts; broke chat in master
  * fix: don't redirect on jquery logout
  * logout without refreshing page on Sales
  * fix: Sales after-login working again (oops)
  * fix: git-extras disappeared?
  * cleanup homepage
  * misc. ui
  * misc. Sales tweaks
  * adds a Placeholder menu type
  * cleanup
  * fix: Editor buttons clickable again
  * removes mutant dependency from Sales page
  * - globals
  * hoping to add globals.js to the production bundle
  * fix: remove locally-stored user in forum app & sales app
  * no more double-marshal of locals
  * fix: hostname click/focus
  * removed many conversation_* stored procs
  * Merge remote-tracking branch 'origin/prod'
  * fix: use pre-compiled stylus on production Sales
  * Merge branch 'master' into chat
  * fix: cache-url in production
  * fix: left nav correctly draws when scrolled
  * fixes: fb share icon clipping & post date wrapping
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * last round of tweaks from yesterday
  * solarized tmux for root
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.build-all-uris site-id before upconverting
  * fix: cookbook
  * Merge branch 'master' into prod
  * fix: init default menus on deploy
  * fix: load waypoints in production
  * Merge branch 'master' into prod
  * fix: optimized builds working again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + ack, too
  * Merge branch 'master' into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of configs specific to my systems
  * vim bundles
  * don't want git submodules of vim bundles
  * merged
  * added symlink for prod. plv8
  * added symlink for prod. plv8
  * deploy in a single step, added steps + cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' into chat
  * our latest recipes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default vim config
  * default vim config
  * removed unfinished feature from ui
  * fix: crash from bad user input
  * eMkel tweaks
  * Merge branch 'master' into chat
  * prevent crash in posts.jade when social is not available
  * Merge branch 'master' into chat
  * expose post.media_url and post.images in db.forum.summary
  * fix bug where top post would lose its media_url
  * insert images and assoc them to posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' into chat
  * add images.{created,updated} timestamps
  * table for thread subscriptions
  * table for following users
  * reload -> reloj
  * fix: use first domain in admin switcher
  * admin group for Look & Feel
  * fix: prune multiple *.pb/*.powerbulletin domains from membership list
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reload after choosing user name for 1st time on private site
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * mark that the sender of the message has seen the message
  * Merge branch 'master' into chat
  * ported reload(module) from wm code; seems to work in the repl now
  * more chat related db queries
  * Merge branch 'master' into chat
  * fix: exclude current site from admin switcher
  * admin site switcher
  * fix: completely reload social links every mutant load
  * organized General Admin w/ collapsable SEO Options
  * + admin-able social links for forum pages!
  * added a toggler for PanelCollection
  * more cross-browser & bigger tooltips
  * Sales & MiniSiteList polish
  * Merge branch 'master' into chat
  * cross-browser compatibility++
  * remove deprecated chat server handlers
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: defer user lookup to avoid null case
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't print times on server-side, let client figure it out
  * Merge branch 'master' into chat
  * fix: tie editor local storage to user.id
  * fix: tie left-nav ui settings to user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: anchor /admin redirect to beginning of url.pathname
  * announce to right path, removed to-id param from chat.send
  * misc. Sales ui
  * on-personalize for @page
  * connect.sess cookie expires in one year
  * misc. ui++
  * post & comment actions wip
  * marked up latest spritemap
  * dropped another design b0mb on Sales
  * active thread arrow responds to nav size
  * comments on db.conversations.{participants,between} fns
  * chat.send c-id, from-id, to-id, message, cb
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.conversations.participants c-id, cb
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * signatures in post views!
  * db.conversations.between site-id, users, cb
  * less confusing cursor style (default arrow) for disabled controls
  * db.$table.attrs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: z-index from covering FAQ, etc...
  * hardware accelerated parallax
  * new image includes radial blur to speed up scroll
  * pruned old images (cleanup)
  * remove stray console.log
  * fix private site issue
  * brainstorming with beppusan
  * fix: can't remove the middleware
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * SuperAdminUsers ready for bigger changes
  * require prelude-ls, remove comments and console.logs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resolve conflict and make disable/enable more accurate
  * close tooltip unless message
  * removed hack & destructure show-tooltip exclusively
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * removed SalesRoutair
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of throttle on scroll
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui, animation timing & dom simplification
  * newline in front makes it look better in firefox
  * accidentally checked in debug code
  * typo
  * standardize on select-one, select, update-one, update
  * menu.extract doesn't have to stringify page.config anymore
  * guard against null thread_count
  * forgot to handle err
  * temporary hack to prevent excessive handlers from being set up
  * first pass on forum chat bubbles
  * layout chrome++
  * added arrow to left-nav active thread (from comp)
  * latest spritemap
  * fix: colors for dark theme
  * save nestedsortable tree state in local storage
  * seo++
  * fix: no more #forum_background_color dups
  * handle++
  * fix: reap background_color
  * fix: remember left-nav width after collapsing & refreshing page
  * background color for forums, forum homepages & profiles
  * sets up primary & secondary overlay & tint colors
  * ++(Add User & Invite)
  * Revert "pages may override any path, even /"
  * fix: more cookie removal (oops, missed a spot)
  * fix: misc. stylus
  * fix: load order of Sales
  * fix: delete user local storage on logout
  * smoother scroll
  * darker images w/ transparency applied
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest Sales page!
  * Merge branch 'master' into chat
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pages may override any path, even /
  * fix: rounded photos clip properly
  * fix: Editor crash
  * refactor: replaced $.Cookie with local storage
  * wip
  * explicitly update local storage user from socket.io
  * fixes & embellishments to Editor & mutant
  * Editor has preview toggle using local storage
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add chat panels when chat button is clicked]
  * window.components.panels = new PanelCollection
  * Editor no longer saves randomly
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: autosize on profile mutant, too
  * faster, non-blocking on-personalize w/ local storage
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixing icons, playing w/ positioning
  * simplified Editor w/ lodash.throttle
  * upgraded lodash -> 2.3.0
  * use local storage with Editor component
  * wip panels
  * counting threads (humanly) on profile pages and then some
  * editor pop-ups now in PB flavor
  * *bomb* on profile
  * local storage api
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes for Editor & Sales
  * console flair
  * fixed syntax error
  * tie signature into user
  * Editor saves one last time before detach!
  * signature saving!
  * fix: only save whitelisted alias.config keys
  * fix: escape to close all Auth inputs, too
  * escape to close Editor
  * automatic setup of serialized db functions
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: sales transitions are back, oops
  * misc. ui
  * latest Editor
  * fix: crash when searching
  * preparation for automagically setting up basic select/insert/update/delete for tables with ids
  * /auth/once-admin
  * misc. fixes sitting w/ beppusan
  * fixes: misc. stylus ui
  * optimization: only swap forum backgrounds when different
  * smoother forum transitions and then some
  * MainMenu component++
  * 3rd pass on Sales page
  * + PageDown npm, whoops
  * + initial Editor component
  * + PageDown, loading now w/ requirejs
  * black is the new pink or more auth+controls ui
  * *bomb* 2nd pass on Sales homepage comp.
  * fix: is the css animation affecting clicks?  let's find out...
  * testing "oval" fancybox theme on privatesite
  * beginnings of new sales page et. al
  * fancybox black edition
  * be careful when joining aliases
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactor: consolidated SalesApp into Sales
  * summary wasn't able to see threads with only one post in them
  * reformatted sql for db.forums.summary
  * join aliases against both posts and forums
  * added counts to db.aliases.participants-for-thread(thread-id, cb)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: use lowercase (more globally appropriate)
  * tidy: store forum backgrounds in /bg/
  * commented out media_url from homepage
  * migration for images table
  * db.forums.summary(id, cb)
  * db.sites.save-style(site, cb) extracted from pb-resources
  * stubs for ChatPanel component
  * added hide and show methods
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix bug where wrong alias.name could show up in profile
  * misc. Auth ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.aliases.participants-for-thread(id, cb)
  * PhotoCropper enhancements
  * - body on homepage view
  * black #theme
  * panel wip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * server-helpers.dev-log-format (wanted hostname in dev logs)
  * fix: hide last activity if none
  * update user title over socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes: homepage
  * fix: limit set-profile to tools menu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * touch aliases.last_activity on registration
  * added 12-time to strftime
  * fix: oops, spacing
  * using minified strftime
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to add symlink
  * left-nav looking closer to comp.
  * adds last activity & titles to forum posts
  * strftime and friendly dates on the client side
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * moved add-dates back to shared-helpers
  * opaque login dialog on private-site
  * initial pass on user titles
  * secure aliases update to site
  * notes for beppusan
  * fix: friendly time reversal & human fn bolding
  * last_activity and friendly dates
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added _friendly dates (Day Month day, YEAR)
  * installed strftime
  * moved add-date to server-helpers
  * profile page ui
  * fix: keep "Posted" outside of date fns, into views
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * start of aliases resource + rights
  * just in case user is null
  * touch aliases.last_activity on login, logout, connect, disconnect
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + last_activity
  * fixing weird bugs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check for length differently
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' into no-orm
  * removed thin-orm node module
  * replaced code that used thin-orm
  * select1 and updatex for aliases, pages and subscriptions
  * fix: show .summary on new forum reply
  * fix: must be wider for beppu's wide-ass resolution
  * fix: min-height isn't necessary anymore
  * fixes: // -> / in photo resource + no-longer escaping html
  * incorporating emkel comp. with our own flavor
  * reply textarea grows among many ui enhancements
  * added deserialized-fn and updated select and update fn generators
  * resolved conflict
  * fix: "Posted" in time updater, too
  * add Posted to posts & escaped <html> for security: XSS, etc...
  * more homepage & forum ui
  * main menu++
  * Sales* refactor + cleanup + fixes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. fixes for older browsers
  * beautiful crash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip saving user/alias info
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass of combining fulltext search with users.all query
  * wip for db find fn
  * Merge branch 'master' into no-orm
  * db.aliases.update1(obj, cb) and db.users.update1(obj, cb)
  * mark all spots where thin-orm needs to be removed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added db.posts.toggle-sticky(id, cb) and db.posts.toggle-locked(id, cb)
  * added db.posts.upsert
  * content-only admin feature working!
  * fix: don't submit on enter key
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix unit tests broken from commit e2ec4c37cf4fb98ae9293700447b7b7f4b21d397 (elapsed-to-human-readable)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix #warning
  * fix: don't crash if tooltip is non-existent
  * user admin paging + styling
  * constrain list of users by site.id
  * cats.pb.com => community; sorry mr.clifton
  * fix: AdminMenu tooltips
  * profile++
  * SEO, layout & human-time improvements
  * replaced head.js entirely with requirejs + cleanup
  * fix: hide/show "Change Password" if editable -- oops
  * cleaned out plax and misc. ui
  * admin checkboxes auto save and then some ...
  * low-hanging fixes
  * added memberships to MiniSiteList
  * secure cookies!
  * if user lookup fails, don't crash
  * forgot we went back to using name (instead of email) in session cookie
  * fix: only delay MySites for @login
  * fix: build register link in immediately
  * Merge branch 'auth'
  * bug fixes for joining a site and choosing a username
  * disabled parallax viewport
  * allow existing pb.com users to choose username when joining a *.pb.com site
  * Merge branch 'master' of github.com:khoerling/powerbulletin into auth
  * server-side for existing user joining a site
  * sensible auth field blanking
  * adds "Change Password" to profile page among more ui
  * help @login find the info it wants
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * rights management WIP
  * bold numbers and their metric for human readable
  * profile page has latest activity date among other ui
  * hide footer unless scrolled
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * delay creation of default aliases until auth-handlers.choose-username
  * using css to switch checkbox label text, eg: on/off
  * first pass at rights library which will be used for rights logic everywhere else (including handlers)
  * sql syntax error fix
  * forgot to JSON.parse some user and alias attrs
  * user.sys_rights for matt
  * resolved conflict
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * private site intro round 2
  * fix: crash if background doesn't exist
  * Merge remote-tracking branch 'origin/master' into auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hide title in reply drawer & focus ckeditor on reply
  * tighter post layout, profile page is more obvious & misc. spacing, colors, etc...
  * moved all site stylus into public/sites/SITE-ID
  * fix: added domain-id to site's auth.styl
  * all tooltips stay visible longer
  * add default aliases on 3rd party auth registrations
  * hide passwords by default
  * fix: always leave a modal dialog open at all steps in auth for private site
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * be more generous with module timeouts in requirejs
  * fix crashes that prevented default aliases from being added
  * bumped up pagination
  * bumped up pagination
  * add default aliases when new users are created
  * use conditional inserts for adding default aliases
  * fix: re-enable submit button
  * Merge remote-tracking branch 'origin/master' into auth
  * fix: migrate in production
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: migrate in production
  * Revert "upgraded uglify -> uglify2 through grunt-contrib"
  * Revert "upgraded uglify -> uglify2 through grunt-contrib"
  * fix typo; i thought i did?
  * Merge remote-tracking branch 'origin/master' into auth
  * add system rights, update user editor accordingly, backend code still needs some work before the loop is complete
  * don't count javascript twice
  * add bin/cloc for code metrics
  * merged
  * merged.
  * Uploader component can delete
  * simplify render-component so it only uses the initial case and doesn't require the programmer to think about reusing component classes
  * checkin WIP for UserEditor, mainly server-side and validations are all that are left
  * fix: rebind expand & collapse behavior after addition
  * Merge branch 'master' of github.com:khoerling/powerbulletin into auth
  * add default aliases to user on local registration
  * db.aliases.add-to-user(user-id, site-ids, attrs, cb)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ui love to user admin & table
  * fix: oops, AdminMenu working again
  * use cache server to load socket.io library instead of socket.io directly (prone to crashing), simplify varnish config
  * Merge branch 'master' of github.com:khoerling/powerbulletin into auth
  * s/Help/Forgot/
  * when user not found, fail gracefully and correctly
  * init pb-models; fix io-server bitrot
  * made failure messages vague (on purpose)
  * AdminMenu fixes & folding
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * re-usable Uploader component
  * Merge branch 'master' into auth
  * use db.users.by-email-and-site where appropriate
  * add user.site_id for current site_id
  * refactor css so keith doesn't yell at me
  * edit user ui first pass
  * forgot that user.auths was an object (not a list)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix auth for SalesRouter
  * whoops
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. vanity
  * db.users.by-email-and-site email, site-id, cb
  * race condition fixes for private site
  * upgraded uglify -> uglify2 through grunt-contrib
  * url generation abstracted away from SuperAdminUsers component
  * user admin in forum app first pass, pagination works on initial load only, need to add url to forum-urls lib for client mutations to work
  * comment on users.email 'local auth email'
  * misc. ui
  * private site++
  * start AdminMenu collapsed
  * expanding & hiding AdminMenus
  * fix: crashish when !user
  * fix: crash if socket.io doesn't load
  * future TODO notes
  * misc. up w/ beppu
  * frontend for login with email
  * login with email instead of alias.name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: correctly update version in a single transaction with up
  * after 3rd party auth finishes, set reactive var r-user if it exists
  * run bin/migrate at end of create-pg
  * save site.config.private correctly
  * fix: crash
  * fix: sql fat-fingering
  * misc. admin & more translucent theming
  * parallax & auth dialog diming on private site
  * slick grow fx for private site background transition
  * fix: guarantee auth dialog shows on private site
  * preparing chrome for translucent tint-color/backgrounds
  * fix: don't show footer reply except html.forum mutants
  * verbiage changes & friendly placeholder for User Admin
  * fix: forum backgrounds have tint directly applied
  * misc. frontend to Buy & Sales
  * migrate reports more usefully + 2nd migration
  * rotate & fade-through all forum backgrounds on private site auth
  * verbiage
  * background refactor & bug-fix
  * Sales++ & MiniSite++ & Cross-browser
  * Better Buy experience
  * post/edit interface++
  * *b0mb* on Site List
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * *bomb* on sales
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * make stdout from backup script more helpful and include a timestamp
  * update readme, had to tweak crontab again
  * add crontab notes to README
  * bin/remote-backup script
  * fix: cache-bust on write
  * SuperUserAdmin placeholder
  * misc. ui
  * cleanup
  * migrations (first pass)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use normal 404 handler instead of custom
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tamed mainmenu, readying drawer ...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * numerous code cleanup, bugfixes, and tweaks for SalesRouter, and SuperAdmin
  * powerbulletin key & secrets!
  * fix: race condition between sales-entry & layout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check for error condition more explicitly
  * misc. ui improvements & cleanup
  * automagically show site list if logged in
  * consistently report errors, fixed register/auth tooltip, etc...
  * fixed bug in register-local-user where guard was too strict
  * server-side guard against invalid domains
  * a little more kosher ;)
  * remove stray space
  * sales & site list++
  * forum ui++
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: crash if site hasn't got config
  * fix: cleanup backgrounds
  * wip on cli product subscription script
  * fixed typo
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. colors & cleanup
  * double-buffer backgrounds between forum changes
  * added admin user for site_id 1 (pb.com)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * show a different msg when user has no sites
  * lazy-load + animate background <img> on private, homepage & forums
  * link to admin
  * added callback to @login-with-token
  * implemented #once-admin for going logging in and going to /admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pass site info to MiniSiteList component
  * styl for mini site list
  * fleshed out template for mini site list
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * background on private site mutant!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to pull in sort-by fn
  * route for list of current user's sites
  * added user_count and return list instead of object
  * forum backgrounds work at the thread level, too
  * fix: clickable region
  * fix: always set active
  * fix: Uncaught TypeError: Object [object global] has no method 'rUser'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass at forum backgrounds on frontend
  * really fix mainmenu offscreen slide
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hook up MiniSiteList to SalesApp
  * db.sites.owned-by-user(user-id, cb)
  * component for mini site list
  * more evil yoshida & eMkel comp. ui
  * fix: main menu won't snap back n' forth with big submenu content
  * fix: don't crash on blank menu
  * made reactive far window.r-user work again
  * added link to My Sites
  * misc. ey ui
  * per evilyoshida: removed jquery-nicescroll
  * addressing some evil yoshida feedback
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: profile login/out link bug
  * full urls for SuperAdminUsers
  * code cleanup, add gen (opposite of parse), and fold mappings into urls file
  * added Reply button in footer from comp.
  * fix: footer resets left on homepage mutant and then some
  * oops, forget 1px transparent image
  * cleanup
  * everything part of forum backgrounds save to server
  * adminmenu forum backgrounds have thumbnails
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: main menu scrolled offset & potential crash
  * fix: reload MainMenu component after blasting away
  * know when sighup triggered restart
  * in domain section of admin, default to current domain
  * added links to sites where you can request api keys
  * beppusan is now admin
  * fix: never detach main menu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * back/forward working between super & sales
  * put switch-and-focus on window so 3rd party registration works again
  * SalesRouter immediately blasts content out of DOM
  * Revert "fix: mostly covers fancybox"
  * fix: mostly covers fancybox
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix querystring issues with surfing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum background wip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * delete existing passport for domain so new one can be created
  * factored move into server helpers
  * translucent footer
  * pass active-page local from server
  * remove console logging
  * latest SalesRouter tweaks, routing is now integrated into SuperAdmin states (and urls)
  * routes are now mapped to SuperAdmin states, drilling deeper ; )
  * Merge branch 'salesrouter'
  * fixed bug duh
  * populate route local automagically in top-level components
  * implemented traditional thread sorting (by date of last post in thread)
  * admin & main menus++
  * forum background wip
  * lightly move footer out of the way & back
  * SalesRouter now knows how to touch a reactive variable 'route' instead of changing layouts when moving between routes which map to the same top-level component
  * remove items which don't belong in version control
  * s/user/req.user/
  * disallow non-admin posts from locked forums
  * removed debug msgs
  * stickiness trumps all when sorting top level posts
  * misc. profile, paginator & layout improvements
  * comp'd out profile/tools menu
  * show/hide scroll-to-top & matches comp.
  * pager styled like comp.
  * scrolling alignment among other ui fixes
  * sales router now reaps old top level components after 3s
  * Merge branch 'master' into salesrouter
  * cleanup
  * got rid of unnecessary default param values
  * note for possible future expansion of moderation log
  * code alignment
  * make sure there are no undefined states in state machine
  * changed misleading comments
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tooltip to prompt admin to select a menu item type
  * fixes: main menu
  * using MainMenu component--working quite nicely!
  * numerous ui tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: main menu stays open without losing the hover due to padding shrink
  * added placeholders and guards for page and forum slugs
  * set default profile pic on registration from sales app
  * marketing notes
  * add validation so that uri's must always be present
  * misc. frontend improvements: main menu/layout/logo/textual
  * fix: crash if no uri
  * fixes: parallax
  * only parallax images in view when scrolling
  * fixed bug in struct-upsert
  * fix: parse-int each item before using maximum
  * latest menu ui, looking sharp!
  * intelligently reposition main menu when offscreen
  * Sales+++
  * switch ui control++ (ios7-themed)
  * added testing harness for new main menu
  * Sales Page:  generic arrow (animated) + cleanup
  * improved focusing & scrolling behaviors
  * main menu jade mixin has recursive depth tracking
  * + move down animation
  * tune the Paginator to be more consistent with the visibility of First/Last
  * add arrows to Paginator component per emkels comp
  * Ready to begin fleshing out main menu
  * fixes: Sales
  * common controls++
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * ios7-style switches
  * fixes: ui error class & logo
  * first iteration of Table component, combination of normal table, and paginator control
  * remove file from version control which doesn't belong
  * no need to put requirejs-config in server-side locals, it is loaded in a self-contained module now
  * exorcise datatables
  * fix forum filtering in search in light of menu change, fix reinit-elastic script to point to new log file
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * initial MainMenu component
  * only allow items with a type to be sorted
  * sales page waypoints
  * fix: menu admin gap
  * cleaner common controls
  * menu admin++
  * fix super-admin navigation links
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * sales focus & finesse
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added nav to sales page
  * offline in development
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * menu-item.forum-slug needs to be old-item.uri
  * give newly created sites a site.config.menu
  * menu.upconvert wasn't handling forum.uri correctly
  * forum urls weren't working
  * misc ui
  * Revert "upgraded jquery waypoints"
  * AdminMenu *b0mb*
  * stdui++
  * upgraded jquery waypoints
  * fix: title crash on main menu
  * fixes: reply-related focus issues
  * fix: - ui background colors
  * top/right profile & standard controls +++
  * fix: reply no-longer steals focus
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * always resize left-nav
  * misc. admin ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * menu has to be generated after forum uris are generated
  * notes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * users.photo moved to aliases.photo
  * fix: page layout::static runs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to add app/views/menu.jade (wrapper around mixin)
  * fix: on-unload crash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: active menu highlighting, and then some!
  * handler for menu-update socket.io msg
  * make site var available to @homepage
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * always show default avatar
  * emit a menu-update message to all clients when menu is updated
  * Merge remote-tracking branch 'origin/master' into menu
  * just one to grab the first parent when deleting from dom
  * using site.config.menu everywhere!
  * fix: f (forum)-> menu + draws correctly
  * Merge remote-tracking branch 'origin/master' into menu
  * fixed saving of external links
  * Merge remote-tracking branch 'origin/master' into menu
  * finally defeated the focus bug?
  * replacing forum-based main menu with site.config.menu
  * move initial attach code into attach phase of SalesRouter
  * add notes on how i re-init postgresql with utf8 forced
  * code cleanup, it had gotten kinda gnarly, real deal, ask beppusan :D
  * misc. ui w/ emkel
  * misc. ui w/ emkel
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * make sure fancybox is visible when appropriate
  * relocate auth tag
  * properly embed Sales in SalesLayout
  * w00t can now embed layouts on the fly with SalesRouter
  * fixed the sales optimized build
  * initial page loads now properly attach to existing dom nodes without a re-render
  * remove dead code
  * log message to console when skipping render and only attaching
  * a little code cleanup and some bugfixes
  * history state integration with SalesRouter
  * code cleanup, bugfixing, and don't explode when trying to navigate to an invalid url, return early and politely warn the console, bound to happen alot in production, don't wanna hose the javascript app
  * menu update should be better; still have some focus issues
  * some code cleanup, hook up SalesRouter to History api
  * bugfixes and css for page transitions in SalesRouter
  * misc. ui
  * social auths on login & register dialogs
  * fix: auth stylesheet back in business
  * bundle of ui fixes
  * can mutate from button clicks!
  * body.disabled puts a gloss over screen
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unsuccessful attempt at fixing menu update issue
  * w00t, optimized build works now
  * tweak waypoints
  * fix typo
  * cdnify waypoints, tweak optimized js builder so it builds correct dependencies
  * more comp. on the forum
  * components can now be uglified
  * yay, i think maybe i solve uglify problem, testing now
  * various tweaks, and bugfixes
  * checkin latest wip, can now navigate between two sales pages, need to now hook up css for correct hiding behavior
  * holy crap, it actually sorta works, more polish to come, checkin wip
  * checkin wip, major refactor, routing is coming together nicely, will get back to superadmin after i reach a stopping point here
  * *bomb*
  * SalesLoader becomes SalesRouter
  * create sales-urls in same spirit as forum-urls but super simple for now until we need something more complex
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * another step toward fixing focus issues
  * check in work in progress for site admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * design bomb on wrapper
  * focus on something sane after deletion
  * append $sub-ol to right element containment
  * fix: display logged-in profile
  * forgot to call reverse!
  * responsive sales page (for mobile)
  * on menu save, return database id on success
  * attempt at recursively deleting menu items
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added menu.flatten(menu) to flatten items prior to deletion
  * fix: oops, pruned .js
  * moderation -> censor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * upgraded jquery to 1.10.2 + cleanup
  * implemented menu.db-delete to remove corresponding menu-item data from the database
  * added delete-fn
  * handler for menu item deletion
  * remove menu item from dom on successful deletion
  * new spritemap
  * use dev pem in dev again...
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * avoid logging sensitive information in production
  * now there is REALLY no logging in production for requests ; )
  * add papertrail shell script for watching app logs, ONLY FOR PRODUCTION ;)
  * use production pem in prod, (need to use symlinks for this and use logic), decrease timeout in case of dos attacks (testing without cache reveals this problem)
  * Merge branch 'master' of github.com:khoerling/powerbulletin into prod
  * Revert "load socket.io from right url in lazy-load"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum.slug is just the basename
  * add authorization urls for Matt's blitz.io accounts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * work on fixing focus bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * improved error checking & ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make sure dbid is set correctly in menu.extract
  * + reap binary
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * delete wip
  * misc. comp style
  * added @build-nested-sortable to recursively draw site menu in admin
  * load socket.io from right url in lazy-load
  * added dbid to admin menu
  * report errors better on failure
  * added some error handling to menu.db-upsert
  * updated docs in shared/forum-urls.ls regarding moderation log
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix an ie bug
  * ++Sales
  * admin ui & sales page build-in ++
  * only run bin/powerbulletin in production (faster)
  * added reap & reaping /tmp every 30 minutes
  * disable optimized build in production, it is messing up load order -- needs some tweaking
  * hopefully fix shim config
  * add env to bin/build-requirejs-optimized
  * standardize on strings for menu-item id because nested-sortable's to-hierarchy uses strings for ids
  * no need to require other libs
  * surfing is fixed in IE9, had to use the html4+html5 history.js bundle instead of the html5 only one
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix socket.io in IE, ie still broken but console exceptions cleared on IE9 (click handlers for anchors arent working)
  * menu.upconvert(old-menu, id-fn)
  * comment spacing
  * ability to resort menus (rough)
  * stub for server side of resorting menus
  * removed accidental mutation from menu.struct-upsert; added more docs
  * added docs for move; removed reorder, because move can handle that case without extra work
  * implemented menu.move in terms of @item, @insert, and @delete
  * made menu.insert not mutate original menu and fixed splicing bug
  * fixed bugs in menu.path and menu.delete
  * admin menu supports up to 3 nested now and misc.
  * fix: don't always show profile photos (left nav)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added menu.item and menu.delete helper functions
  * fixed bug in menu.reorder for handling case when old-n > n
  * new post action buttons and then some
  * fix: oops, fat-fingered jquery cookie
  * + new default avatar
  * offline development working again
  * misc. ui bundle
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + spritemap
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added menu.reorder function (for special case of move operation)
  * provide place to store optional database id for menu items (different from nested sortable id)
  * uncommented upsert
  * misc. menu-to-comp.
  * improved Sales <head>er
  * shrunk scroll height by ~15% for shorter resolutions
  * More sales ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + new favicon
  * moderation log wip at /m, fix race condition bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix a buncha race conditions
  * fleshed out rest of state table
  * check in moderations page wip
  * fix repl
  * some refactoring, avoid repeating things twice
  * some small stylistic tweaks, hide all modules by default, add a second module for Site editing
  * fixes undefined header Access-Control-Allow-Origin and sets it to '*'
  * update jquery to latest point release of 1.x branch, cdnify several urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add the full plethora of cache domains to the window
  * finesse
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * checkin wip SuperAdmin component with first child module 'SuperAdminUsers'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sales page ui *bomb*
  * new animation on sales page & better build-in
  * fix realtime search for initial page load
  * Cache-Control: no-cache for search page
  * remove one round-trip due to an ssl redirect, make socket.io delivered files able to be delivered from muscache
  * necessary to get grunt working
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * compile js and run requirejs optimizer in production
  * tune bin/develop, bin/diediedie, and bin/launch
  * background-image -> <img> and more ui
  * dropping design bombs, working through a couple ideas...
  * fix: hide reply drawer when creating a new post
  * fix: io-server/pb-rt crash
  * header ui: search, scrolling, etc...
  * more cleanup (app)
  * grunt working with bin/develop
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * earlier bits, beginnings of ui greatness
  * Merge branch 'requirejs'
  * made pure-validations compatible with both plv8's require and amdefine
  * build script to build optimized sales app bundle
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * sales app works with requirejs
  * forgot to pass site-id to user-fields in u.top-posts
  * Merge branch 'master' into requirejs
  * make 3rd party logins work again
  * these keys were for mma.pb.com
  * Merge branch 'master' into prod
  * commented out upsert functionality in resources for now; res.json success: false instead of next err to prevent crashes
  * added menu.upsert for upserting various menu-item types
  * tweaked menu.extract function
  * edited function comments
  * removed dead code; wip on menu saving
  * added menu.find and menu.path
  * blue color defaults for sales + comp.
  * fix: footer correct width in admin mutant
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * adapted menu.extract and menu.mkpath to new reality
  * layout+++ (more comp.)
  * auto focus first input after selecting AdminMenu type
  * more pager cleanup
  * don't export insert-statement, update-statement, and upsert-fn
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.pages.upsert and db.forums.upsert
  * using stylus variables for color, etc...
  * recombining AdminMenu forum with nested sortable
  * playing w/ tag colors
  * use variables for tag colors
  * Merge branch 'master' into requirejs
  * fix: fix: better disabled this way
  * temporarily disable pager
  * latest design bomb
  * fix: wide-style left content again w/ avatars
  * resize footer to left-content
  * all stylus colors in variables
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * pulled in prelude here and there
  * ignore elastic-logs folder
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * split SocketApp into its own process pool (so now we have app, cache, and socket pools, and additionally the indexer and the search notifier
  * saves menu & active form (one-at-a-time)
  * wip for making sales page work w/ require.js, too
  * undo patch to nested sortable for .data() attributes
  * ui flow: hiding & showing admin menu type
  * Merge branch 'master' of github.com:khoerling/powerbulletin into requirejs
  * notify when we are testing http cache, sleep a bit longer before launchning appserver in dv mode
  * cache /socket.io/socket.io.js for 1 year by fixing up the headers in varnish -- also setup cache-blowing via project changeset
  * tweak bin/diediedie and bin/develop to be more courteous with mon
  * overhaul mon/daemonization process, use one uniform technique to figure out how to kill old mon instances which does not involve pidfiles
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into requirejs
  * re-structured with beppu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip on saving menu
  * upgrade elasticsearch to 0.90.3
  * automated in chef adding symlinks for the plv8 procedures and the elasticsearch config
  * nodejs recipe overhaulin
  * misc. forum ui
  * disable unit test for photocropper (was broken)
  * disable unit test for photocropper (was broken)
  * Merge branch 'master' into requirejs
  * fix: correctly store textarea & checkboxes
  * fix: keep saved titles
  * fix: json.parse if array or string
  * active ui for admin menu type (up top)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * admin menu cleanup & ++
  * admin menu ui mostly working!
  * added active ui for selected admin menu item
  * playing with hashtag padding and borders
  * fix indentation mistake, whoa don't know how i missed that lol
  * fix private site mutant
  * Merge branch 'master' of github.com:khoerling/powerbulletin into requirejs
  * more chat fixins
  * fix some bugs on the profile page
  * renamed first param of mkpath so path lib not shadowed
  * add uri attribute to menu-item nodes (similar in spirit to forum.slug and forum.uri)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed bugs in recursion
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * an experiment in recursing through site.menu.config
  * admin menu save/restore wip
  * configure cache-busting with requirejs, EASY, DONE
  * - jquery.deserialize
  * fix optimized build for legacy stuff, client-jade needs to get loaded after component-jade so that it takes over window.jade.templates (argh i hate global crap)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * saving new object-style form data
  * tweak tweak
  * re-swizzle bin/diediedie
  * Merge branch 'master' into requirejs
  * install requirejs (so we can use the optimize script)
  * support for optimized builds in prod now, works, share config in one location for requirejs
  * change top-right profile pic when user and uploader are the same
  * fixed drag and drop profile uploads
  * authorization guards for /resources/conversations
  * hoist env to window so its uniform on both server-side and client-side, fix search, fix another bug where  was assumed global so required like we should
  * fixup unit tests since file location changed
  * remove some console logs
  * couple bugfixes for drawer, ck-submit-form _has_ to be on window
  * bin/develop script as stopgap to replace browserify flow
  * admin bugfixes
  * Merge branch 'master' into requirejs
  * it seems that the sales app is still intact, I am going to leave it alone for now with the headjs config, so we can do this requirejs factor in smaller pieces
  * more bugfixes for main forum app
  * fix admin -> domains initial load
  * use the correct post-count
  * latest wip
  * fixed db.posts-by-user to not return too many results
  * comments work
  * can now create thread with requirejs branchg
  * need to think about server side menu data more
  * fix thread pagination
  * homepage/forum/thread pages all work
  * Merge remote-tracking branch 'origin/master' into prod
  * more tweaks, now all that is left is mainly global cleanup
  * oh snapz, varnish was cutting off the stylesheet at 5s before stylus could complete (~8s), this fix should greatly improve static file reliability in addition to the other fix, but this one is safe enough to cherrypick into master @smurf0r and it should help alot
  * start weeding out global manipulation, fix another bug
  * worked around mutant sloppiness for now (mutant was referencing our client-jade templates directly)
  * shim in all our jquery libs
  * check in latest WIP
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * converted more libs to use @
  * converted client/tasks.ls
  * removed console.warn \avatar
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * whoops; this is the socket.io profile pic change
  * resolved conflict and added socket.io profile pic updates
  * + .tiny-grow
  * site-specific stylus using cache-buster!
  * -> livescript 1.2.0
  * factored cache-buster into server helper
  * Revert "use regular domain for site stylus"
  * + logo icon
  * cleanup stylus
  * reduce deadline to 1500 on io-server
  * fix pb-cache launcher so it launches both nodes now
  * Merge remote-tracking branch 'origin/master' into upgrades
  * fix: hide profile/summary on new post
  * layout cleanup
  * sales page design bomb
  * cache-buster for avatars
  * teach require.js how to require mutant
  * more progress
  * upgraded npms: express & cheerio
  * upgrade to node v0.10.16
  * headjs restored
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * cache server now has probe
  * generated by livescript 1.2
  * converted client-helpers to not use export to get around requirejs issues
  * isolate cache server to its own process, this will increase reliability
  * hoist max-age up higher so both express.static servers can use it, and restrict .ls files from being served, ever
  * cleanup git history a little by using back-calls for amd definitions
  * images up on sales page
  * AdminMenu misc. & notes
  * checkin latest wip, next on the chopping block: lazy load code
  * fix: post drawer only collapses on success
  * fix: lazy-load fancybox
  * server-side of menu saving (stubs)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check to see if email already being used during @register
  * admin menu wip for beppu
  * everything loads, now just need to shim in a few more things
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: stylus cache url + misc.
  * let Auth.require-login and Auth.require-registration take callbacks
  * more wip, almost got everyting mapped over
  * install amdefine
  * require wip, following down dependency chain
  * remove livescript dep on appserver, beginning of using require instead of browserify - wip
  * update LiveScript and prelude: npm install LiveScript prelude-ls
  * latest sales page
  * improved scrolling functions
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * @profile-avatar // changes to error responses for debugging
  * Merge remote-tracking branch 'origin/master' into prod
  * admin wip, working on save/restore
  * misc. ui
  * be consistent with 1:1 ratio when using gm.resize()
  * Merge remote-tracking branch 'origin/master' into admin
  * added autosize
  * profile photos are circles + updated default aspect 1/1
  * fixes for left-nav/admin & footer drower behavior
  * Merge branch 'cropper'
  * install graphicsmagick via chef
  * route for cropping profile photo
  * fix the time bug
  * use site_id to constrain search results
  * Merge branch 'master' into cropper
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * introduced global.env to allow client and server to check if dev or prod in a consistent way
  * use regular domain for site stylus
  * admin menu wip
  * use regular domain for site stylus
  * Merge remote-tracking branch 'origin/master' into prod
  * Revert "pb owns public/site folder (for admin styles, etc...)"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: clear varnish on style change & cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pb owns public/site folder (for admin styles, etc...)
  * use correct domain during site creation
  * Merge remote-tracking branch 'origin/master' into admin
  * guard tooltip unless msg
  * save jcrop object correctly
  * Merge remote-tracking branch 'origin/master' into prod
  * configured jcrop to be able to handle images bigger than window size
  * Merge branch 'master' into cropper
  * don't hardcode domain for cors requests
  * don't hardcode cacheUrl in component/SalesLoader.jade
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into prod
  * made test a little more loosey goosey until we can add some less brittle testing for unit tests (thinking use cheerio to make assertions rather than raw string matches)
  * building more content & style
  * guard for chatty subdomain input
  * now using transit for hardware accel!
  * setup Jcrop in crop-mode
  * admin save wip
  * switch to crop mode after upload
  * a couple unit tests for PhotoCropper
  * Merge branch 'cropper' of github.com:khoerling/powerbulletin into cropper
  * check in profile / avatar / cropping refactoring crap
  * more work in progress
  * static css in production
  * Merge branch 'master' into cropper
  * add notes
  * give more time before kill -9 processes, more graceful
  * be smarter about purging varnish on deploys
  * set +e when killing workers in case they aren't online
  * deploy fix, launch before starting workers
  * deployment tweaks, try to deploy with minimal downtime
  * autologin after register and don't force verification
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sales enhancements for emkel
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added a query dictionary in pb-models for queries that don't need to be stored procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * caching tweaks for sales app
  * caching tweaks, add changesets to urls from sales app, and to stylus sheet
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + ssl bundle
  * Merge branch 'master' into cropper
  * add production domain to domains table for auth reasons
  * point cdn urls to correct location
  * add mma fixture for production domain
  * sales page+++
  * Merge branch 'admin'
  * admin menu saves & renders initially
  * show Login by default
  * test-prep script for codeship
  * split tests into unit and zombie, run unit tests on each deploy
  * doh
  * deploy hotfix for new secure port
  * fix search pagination, put 'from' in the right spot
  * fixed css for .PhotoCropper .button
  * Merge branch 'master' into cropper
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create and save new random verification string before resending verification email
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sales page++
  * always run onload-personalize
  * Merge branch 'master' into cropper
  * whoops notate in s instead of ms
  * beginning of unit test suite to flush out bug in elapsed-to-human-readable.. haven't found 'bad' value yet ... ; (
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * glossed tooltip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ability to resend verification email
  * Merge remote-tracking branch 'origin/master' into admin
  * design bomb dropped on sales page
  * admin wip, deserialize/serialize
  * + lazy-loaded jquery.deserialize
  * lazy-load sets body.waiting
  * button hover animation
  * snapping together post drawer & post edit/new
  * button hover animation
  * snapping together post drawer & post edit/new
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't allow unverified users to log in
  * Merge remote-tracking branch 'origin/master' into admin
  * added post reply to bottom of every forum page
  * Merge branch 'master' into cropper
  * allow (new PhotoCropper).start to be called with 0 args again (livescript trick)
  * small documentation correction
  * work in progress
  * Merge branch 'search'
  * recency is not factored in reasonably into boosting
  * too many params; put in hash and use default vals
  * simplified PhotoCropper.start
  * Merge remote-tracking branch 'origin/master' into admin
  * menu admin wip (saving nearly done)
  * misc. ui
  * fix: require login for reply drawer
  * disable non-working tests because they need to be fixed
  * thinking about implementing distinct upload and cropping modes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * launch 3 nodes in production on ports 3000-3001
  * only enable photocropper on your own profile
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: reply dialog ui
  * never cache probe
  * prep node with a probe url + varnish prepping for load balancing can handle up to 10 nodes right now (ports 3000-3009)
  * Merge branch 'master' into cropper
  * make varnish respect cache-control: no-cache
  * really really hotfix prod this time
  * elasticsearch security (tested on prod)
  * git ignore tweaks for prod
  * production hotfix, until uglify issue is worked out for sales bundle
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: for save handler
  * Merge branch 'master' into cropper
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * dont provision on deploy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: mutant static crash & cleanup cl
  * style bomb on control button
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * homer says doh
  * force all /auth/* routes to no-cache
  * codeship.io prep
  * ze cropper shows up
  * admin wip
  * only show submenu if exists & delayed dropdown
  * checkin wip for search recency
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into cropper
  * added "cleanup" to bin/powerbulletin
  * fix: sales stylus
  * prepend instead of append new posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest stylistic tweaks
  * Merge branch 'master' into cropper
  * fix: don't crash on general admin initial mutant load
  * Merge branch 'master' into cropper
  * cleanup: pruned ckeditor & bits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add fixture for powerbulletin.com
  * Grunt: exclude Components from minify, cleanup task & create -sales.min, too
  * forgot to pass site-id to u.top-forums
  * removing some console.logs from socket.io code
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: master.styl -> master.css
  * Merge branch 'sales'
  * use new tooltip.styl
  * Merge branch 'master' into search
  * extracted tooltip styles into own file; added it to master-sales.styl
  * Merge branch 'master' into sales
  * fix: re-align paginator
  * added site_id to db.top-posts and db.top-threads
  * upgraded grunt
  * fix: only refresh if privatesite
  * if err, log it before exiting in presence.ls
  * build uris for new sites in fixtures
  * set path for 'chats' cookie
  * prevent db.usr from crashing when it gets bad data
  * make user-for-session more robust
  * added site_id to db.posts-by-user
  * added site_id to db.post()
  * added domain for site_id 7
  * - transient user profile (again)
  * fix: show/hide search input cancel
  * misc. ui
  * fix: hide scroll rails on search page
  * fix: hide/show paginator between mutants
  * Merge remote-tracking branch 'origin/master' into search
  * Merge branch 'master' into sales
  * update zombie
  * Merge branch 'master' of github.com:khoerling/powerbulletin into search
  * last-minute ui tweaks
  * Merge remote-tracking branch 'origin/master' into page-bottom-post
  * chat tweaks and fixes
  * post drawer saves!
  * removed console.warn
  * 404 when /user/:name not found
  * History.back! when mutation xhr fails
  * Merge remote-tracking branch 'origin/master' into page-bottom-post
  * Merge branch 'chat'
  * remember and position chats
  * fix: posts per page used on profile, too
  * fix: reset paginator when leaving profile mutant
  * fix: reset paginator when leaving profile mutant
  * fix: posts per page used on profile, too
  * snap chats to footer
  * remember open chats in cookie named 'chats'
  * Merge branch 'master' into page-bottom-post
  * mutant warn instead of error benchmark info
  * search zombie test
  * update zombie
  * some tweaks to streaming algorithm, my butt dyno says its alot smoother now and loses no realtime events (he he i'm sure someone might prove me wrong but heres to hopin)
  * attempt to increase precision of streaming algorithm and improve robustness
  * show new hit count at top of search results page with effect
  * no auto-reload required as all is handled by mutations fore real-time ticker (to actual post) other tweaks also...
  * tweaks: step into my time machine, darling
  * hoping this tweak will prevent 'leaking' realtime events on accident in some cases
  * allow efficient version of reload except in 1 case (same page), use internal indexing timestamp for streaming elasticsearch instead of created (which was based on postgres timestamp)
  * pagination should be ignored for realtime search, it now is
  * added emkel user & judenfrei fur beppu fixtures
  * fix:  .search, too
  * moved total hit counter back into body among other fixes...
  * fix: 2 breadcrumbs?  weird...
  * misc. search style
  * breadcrumb style for searches, animation down, etc...
  * Merge remote-tracking branch 'origin/master' into page-bottom-post
  * merged.
  * checkin search visual wip
  * npm install gm #graphicsmagick
  * transient cleanup
  * remove jcrop and html5-uploader code from profile.on-personalize
  * Merge branch 'master' into cropper
  * initialize reactive variable window.r-socket as early as possible to avoid race condition
  * working on save
  * Merge branch 'master' into cropper
  * typo s/process.id/process.pid/
  * split out replies & comments (less confusing)
  * fixed z-indexes for new drawer
  * drawer++
  * thread paginator style tweaks
  * Merge branch 'master' into admin
  * Merge branch 'cropper' of github.com:khoerling/powerbulletin into cropper
  * drawer expands/collapses & top-level replies nearly working
  * add endpoint-url parameter to PhotoCropper
  * checkin wip PhotoCropper component
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * new search result notification now is clickable to show new results, perhaps store id's of new posts for next pageload in History push-state so they can be highlighted?
  * Merge branch 'chat'
  * Merge branch 'chat' of github.com:khoerling/powerbulletin into chat
  * Merge branch 'master' into chat
  * fix crash in search-notifier
  * fix crash in search-notifier
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * changed .post .body line-height to 1.5 so text didn't looked so crunched together
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleanup paginator after leaving forum page
  * Merge branch 'master' into page-bottom-post
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui++ and bounce const for beppusan
  * increase t-step to 100
  * merged
  * don't need jquery-history-native anymore
  * upgraded history.js
  * hashtags and at-tags in posts
  * fix: "no method render-mutant"
  * general admin saves site name
  * Merge branch 'master' into chat
  * changed class to .time-title
  * added comma to disambiguate function call
  * Merge branch 'master' of github.com:khoerling/powerbulletin into sales
  * modal fancybox (never close!)
  * Merge branch 'master' into chat
  * made chat be prepopulated with past messages
  * db.messages-recent-by-cid
  * kill all content containers, auto load login dialog & cleanup!
  * made time-updater know about .data-title
  * increase timeout for first chat message
  * POST /resources/conversations calls db.conversation-find-or-create
  * use proper reload instead of location=
  * Merge branch 'master' of github.com:khoerling/powerbulletin into privatesite
  * doh how did i not see this
  * improve documentation, be more anal and make sure homepage is never cached upstream for private sites
  * header & main menu++
  * cover all cases where we need to _not_ cache if the site is private
  * photos & online/offline ui++
  * small fix but toggler still busted
  * let there be private parts. fixed the syntax error
  * remove dead code
  * reload page on login, for private sites to work
  * initial ui state, ready to load & save!
  * cleanup
  * Merge branch 'master' into admin
  * upgraded stylus
  * personal site basics in place, just need to tune and test, also need to popup login dialog for private site by default? .. does login window.location on login cuz it needs to for private sites?? maybe??
  * Merge branch 'master' of github.com:khoerling/powerbulletin into privatesite
  * animations++
  * ignore pb.sql
  * Merge branch 'master' of github.com:khoerling/powerbulletin into privatesite
  * Merge branch 'master' into admin
  * reworked profile/tools menu in header & tamed animations
  * saving wip
  * fix: crash on static load
  * lazy load socket.io
  * ignoring /public/sites
  * merged.
  * Merge branch 'master' into chat
  * non-component css using .main-content & .left-content classes instead of ids
  * bandaid for crashes + transient removal
  * ignore pb.sql
  * removed some log messages
  * stacked signal handlers
  * menu admin wip (before battery dies)
  * persisting chat info in redis instead of process memory
  * show err.stack before graceful-shutdown
  * big merge
  * ui+++ & cleanup
  * merged.
  * wip: better admin style error handling, verbiage & ui
  * site-specific css can be stylus now!
  * + new defaults & cleanup
  * users can save their own site-specific css
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * fix crash and rip out more transient business
  * added Auth.require-registration; require registration before making site
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * private site prototyping... wip, at least the page loads hehe
  * animations++
  * fix: don't cut off last thread in left nav
  * font is back
  * merged -- looks good
  * initial wip for posting at the bottom of each forum page
  * fixed u.user-fields and procs.forum_summary
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * create_site now requires user_id and doesn't care about transient
  * set session cookie value to old 2-item style
  * pruned transient from ui
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * more transient cleanup
  * require-login before site creation
  * Merge branch 'master' into sales
  * Merge branch 'transient_cleanup' into sales
  * Merge branch 'master' into sales
  * added header and ability to login/logout from browser
  * jumbo menu admin update
  * remove console log
  * reset threadpaginator to active-page:1 when changing forums
  * merged w/ matt's static/initial refactor
  * refactoring of render-component to make it more elegant to use... prep work for yet another component i'm adding (thread paginator)
  * misc
  * close on client-side w/o waiting for server response
  * if node gets a SIGINT, clean up socket.io connection info stored in redis
  * Merge branch 'master' of github.com:khoerling/powerbulletin into transient_cleanup
  * woo pagination stopgap WIP... just need to plop view in for left threads
  * modify top-threads so it takes offset and limit, show top 25 threads and hook up paginator.. now just need to make clicks point at something ajaxy
  * Merge branch 'master' into chat
  * fix regression where click handlers weren't always working due to the clever trickery we are doing on the forum/thread pages
  * on-page handler tested and working for Paginator, update unit tests, now need to hook up index/offset to top threads retrieval
  * backup/restore scripts for postgres to make it slightly less painful (not having to scrape again if no schema change)
  * thread paginator WIP
  * render-component requires now a toplevel identifier name (can't always assume classnames are exclusive)
  * Merge branch 'master' of github.com:khoerling/powerbulletin into threadpaginator
  * refactoring of render-component to make it more elegant to use... prep work for yet another component i'm adding (thread paginator)
  * Merge remote-tracking branch 'origin/master' into admin
  * <form> privacy and more ui
  * fix: test fancybox when lazy loading
  * on-personal for admin
  * improved scroll rails
  * + profile image & mutant link in header
  * dropping another design bomb
  * pull down & focus search on header click
  * Merge remote-tracking branch 'origin/master' into admin
  * removed some debug code
  * made profile photos work
  * Merge branch 'master' into chat
  * Paginator tests wip, gonna add click handler capability for paginators which are not url/mutate based
  * don't redirect ssl when dealing with Zombie.js user agent
  * Merge branch 'master' into chat
  * update zombie
  * varnish and haproxy always live on port 80 and 443 respectively regardless of whether dev or prod, this makes testing with zombie easier (local dev + zombie tests can be used at same time)
  * update mocha
  * update test to reflect new output of Paginator component
  * login tests (wip)
  * removed most of cruft from passport, probably a few things left, tested can log in and post
  * Merge remote-tracking branch 'origin/master' into admin
  * checkin latest changes, various style tweaks, reorganizing sales process to 86 transient_owner
  * cleaning up site registration
  * Merge branch 'master' into chat
  * s/isInt/is-int/
  * try this
  * attempt to avoid the crash when clients try to reconnect a little too early
  * Merge branch 'master' into chat
  * fix pagination on profile
  * misc ui fixes and then some
  * async grunt 'css' task works + cleanup
  * Merge branch 'master' into chat
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make sure db.posts-count-by-user takes site-id into account
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * automated schema dumping script, if we skip the migration aspect for now we can easily use commercial tools to sync the database structure, and keep the schema in git... a sort of stopgap between now and when we have time to hack on migrations
  * typo
  * forgot to pass in site.id
  * incorporate site_id into conversation* queries
  * Merge branch 'master' into chat
  * - cssmin & cleanup
  * 2x stacked search header wip
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use pre-generated stylus in production
  * refactor building stylus into server helpers
  * forward port so i can use pgadmin3
  * Merge branch 'master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * send email when a subscription is purchased to sales@powerbulletin.com
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * vary purchase message for fun
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * holy hell, pagination works on profile page, man that was a bitch
  * crash under all environments equally + debounce
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: "on-file" works on the first purchase
  * added bao and reef.powerbulletin.com and conversations.site_id
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * adds slight margin for wide displays
  * placeholder for flat/nested forums
  * adds slight margin for wide displays
  * simplified presence.users-client-remove by requiring a user param
  * authorization phase was blocking cookieless requests from making successful socket.io connections
  * always call presence.leave-all on disconnect
  * only emit leave-site message if user has no more connections to the site
  * introduced redis key "cids:#{user.id}"
  * use redis transactions for enter and leave
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make bbcode allow both uppercase and lowercase tags
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleanup last buy component before creating new
  * Revert "think i fixed bug in production"
  * Revert "fix: buy works again"
  * menu admin wip
  * added Creative & Engineering product
  * re-organize admin nav
  * fixed add-commas
  * for /user/:name/page/:n, if :n is not an int, next err (non-fatal)
  * if the err.non-fatal is true, no graceful-shutdown happens
  * make express-validator available to all routes (not just personalized ones)
  * fixed a broken join in db.posts-by-user-pages-count
  * Merge remote-tracking branch 'origin/master' into admin
  * fix: buy works again
  * menu wip, working on css radio tabs
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * kill mon, too
  * fix regression
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * factor paginator stuff into reusable function
  * Merge branch 'master' into chat
  * pass presence into ChatServer
  * Merge branch 'master' into privatesite
  * think i fixed bug in production
  * made io-server and io-chat-server use debug
  * Merge branch 'master' into chat
  * converted auth to use debug lib
  * make pb-models use debug lib
  * make thin-orm accept an alternate logger
  * Merge remote-tracking branch 'origin/master' into admin
  * powerbulletin now watched by mon in production
  * + debug
  * made realtime site presence work again
  * Merge branch 'master' into chat
  * use presence.ls in io-server
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added regexp
  * make the constructor's cb send back this
  * Merge branch 'master' into chat
  * return an error if we get a bad cookie
  * vim fdm=indent
  * Merge remote-tracking branch 'origin/master' into admin
  * comma'ify + widen search facets (for thousands)
  * Merge branch 'master' into chat
  * Merge remote-tracking branch 'origin/master' into admin
  * fix: search static crash
  * fix: mutant.run for on-initial when initial mutant exists
  * misc. ui improvements
  * forgot to delete rooms:#{cid} on @leave-all
  * Merge remote-tracking branch 'origin/master' into admin
  * added more presence functionality
  * added mike for ui feedback
  * fleshing out beppusan's presence
  * Various preparation for private site & addition of purchase hooks - added hooks for product purchases - added private to multi-domain middleware - re-tool layout-static so it is called with params as this - populate site.config.private on purchase of private site
  * - older socket.io (using top-level everywhere)
  * + redis & hiredis
  * Merge remote-tracking branch 'origin/chat' into chat
  * cleanup paginator after leaving search page
  * draggable working, wip ...
  * Merge remote-tracking branch 'origin/master' into admin
  * + footer scroll to top
  * mad layout, search & paginator love
  * only bench in production and more logs
  * Merge remote-tracking branch 'origin/master' into admin
  * - more client logs
  * Merge branch 'master' into chat
  * removed console.warns out of Auth.login-with-token
  * s/authorize-by-login-token/authenticate-login-token/
  * sketching out api for presence
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * - broken admin menu link
  * menu admin wip
  * let them be admins of their own sites
  * after registering a local user, cb back a user object with the new user id
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into auth
  * after new site creation by registered user on pb.com, Auth.login-with-token!
  * added "reload" to Component
  * make auth-handlers.once-setup use GET
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * me and beppusan hackathon for linking transient users to registered sites
  * disable/enable submit button
  * handlers for login based on auth.login_token
  * auth.set-login-token user, cb
  * db.authorize-by-login-token
  * merged everything up to this point
  * misc. admin ui
  * universal Component render function
  * whitespace
  * if logged in to pb.com and new site is created, create alias for current user on new site
  * db.alias-create-preverified
  * building ui...
  * admin-menu -> yacomponent::AdminMenu
  * added "reload" to Component
  * Revert "factoring conversations out of chat among ui enhancements"
  * Merge remote-tracking branch 'origin/master' into admin
  * invite only 100%
  * misc. ui tweaks
  * fix: forgot swings down again
  * fix: error handling & feature: resends verification email on error
  * if non-transient site created, redirect to \#once
  * reorganized middleware for sales-app; non-transient site creation possible
  * added aliases.login_token to db
  * Merge branch 'master' into auth
  * Auth.show-register-dialog! (for matt)
  * misc ui
  * add subscription tampering to config save and then some
  * renamed product: private_site -> private
  * cleanup before implementing matt's shiney new varnish config
  * rewire varnish to cache even requests which have a Cookie in the request
  * redirect tested successfully, now just need to wipe transient sites before test starts as a prepare measure
  * private site wip
  * another bomb on admin frontend
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * finally! escape from symlink hell when using npm install in /vagrant on vm
  * install zombie: headless testing
  * layout ui++
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: catch masonry crashes
  * update yacomponent, fix typo
  * frontend for privacy and invite only, and then some
  * fix: no more "blank" errors
  * replaced inline handlers with onclick-buy, using data-product='foo'
  * editing tooltip
  * factoring conversations out of chat among ui enhancements
  * fix: load fancybox on the first click
  * b00m fix the transient user bug, can now be logged in as soon as you hit the site, now need to tag team global login with beppusan
  * really check ui for subscription
  * misc. fixes and ui
  * analytics working
  * headjs = head.js
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into auth
  * fix: using site.id instead of user's id
  * fix syntax error
  * fix: config json crash
  * working on analytics & subscriptions
  * misc. cleanup & style
  * fix: credit card validations working w/ matt earlier
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay, i can make cors requests.  now what?
  * remove commas
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove transient user from client code, keep it server-side
  * Merge branch 'auth'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * uniq'd
  * Merge branch 'auth'
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * lazy load fancybox everywhere!
  * clean-out initial load dependencies
  * more wip
  * using head.js for autolo'je instead of jquery.get-script
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * checkin wip, regular users now always override transient users
  * npm install cors
  * fix: restart gracefully
  * io-server has new auth for transient
  * check in latest wip
  * authorize transient users in deserialize-user
  * look at process.env.NODE_ENV (not just process.env)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make graceful-shutdown reload when it's done
  * new user serialization handling in io-server
  * ready for more admin!
  * Buy dialog lists features and then some
  * new schema & fixtures for product features
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * changed user serialization format for passport
  * checkin wip, pass down transient_owner id to user object, wip to handle in serialize/deserialize exclusively
  * added pb.com to domains fixture
  * Merge branch 'auth'
  * finished integrating auth into sales-app
  * chat+++
  * added lazy-load-fancybox() and switch-and-focus() to client-helpers
  * fix: eat draggable click
  * pulled in animation css for sales-app
  * show-tooltip comes from client-helpers
  * Merge branch 'master' into auth
  * setup up middleware for sales-app
  * the beginnings of chat bubbles
  * profile ui fix and gradient main menu
  * Buy submits with return key, disable/enables ui and then some ...
  * Merge branch 'master' into auth
  * moved switch-and-focus to component/Auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * crash fix
  * PB Sales is #1
  * Merge branch 'master' into auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default scrape-mma to site-id 2
  * adding auth dialog to sales app (wip)
  * + jcb image
  * added jcb card and then some!
  * misc.
  * added error handling + tooltip to Buy
  * improved mouse enter region + images
  * added ccv security info and then some
  * + product: super compute instance
  * + diners club card
  * fix another regression, can now once again buy a subscription
  * fix regression where placeholder values were submitting, and fixup serverside code
  * prime-number pricing fixtures
  * added new cc images
  * prime number pricing
  * admin++
  * dropped a design bomb on the Buy component
  * fix regressions on signup process -> transient owner.. now to fill in holes in their user experience
  * pull Component out into its own library yacomponent, and leave only our domain-specific code in component
  * setup as dependency, and install yacomponent
  * fix indentation typo / improve look and feel of AdminUpgrade
  * AdminUpgrade component now disallows buying subscriptions which are already purchased (subscriptions must be passed in)
  * oops checkout needs to always be there
  * Buy component now uses button instead of ParallaxButton
  * enable person to enter different card details even if card saved on file
  * moved the has_stripe logic to where it belongs, on the site object (which correlates to a user)... since a super can subscribe a customer if they have already entered card details (or even if they haven't, they can enter them for them)
  * blank card details is now interpreted as blank card, and hence will then default the customer to their last used credit card
  * fixed Auth.show-info-dialog
  * fix: after login, do!
  * separated invites from forgot
  * added info dialog to auth
  * - outline in nav (ff & ie)
  * fix: load the requested admin page on initial
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't need attach; empty!remove! to remove chat
  * changed method names; no longer need to prefix with 'chat-'
  * moved ChatServer to app/io-chat-server.ls
  * merge conflict
  * guard against media_urls longer than 2000 chars
  * user.hasStripe fix
  * added stripe keys to prod (just testing for now)
  * commit wip for saved card details (once we've been given a card once)
  * fix regressions
  * fix: only submit once with keydown
  * fix: clear ckeditor value after use
  * more cleanup ...
  * forgot password shows activation notice + improved error handling
  * fix height on login and footer opaque
  * only instantiate window._auth once
  * cleanup when chat disconnects wip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ported choose to Auth::choose
  * node_modules/passport-twitter/.npmignore deleted
  * changed default value of users.config to {}
  * upgraded passport-twitter due to twitter api v1 being deprecated
  * ported toggle-password to Auth::toggle-password
  * ported show-reset-password-dialog to Auth.show-reset-password-dialog
  * fix: reusing channels
  * Merge branch 'master' into auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * auth++
  * Merge branch 'master' into auth
  * add more checking to make sure we don't try to subscribe twice
  * it works i say
  * apply beppus thin-orm fix
  * cleanup dead/un-needed code in Component
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * various component tweaks, payment subscription wip
  * rotate strength meter right-side up
  * common js / jsu refactor
  * admin & buy ui and then some
  * misc. button styl
  * fixes + lazy refactor
  * ported forgot-password to Auth::forgot-password
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * place holder buttons for buying custom domain and private site
  * ported register to Auth::register
  * ported login to Auth::login
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * admin upgrade section added, for marketing fluff about upgrades
  * fix: crash in admin
  * Auth::open-oauth-window
  * pimped-out fancybox with secure logo
  * yay, remove componentName from properties in component, now inferred from class name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * payments.subscribe now handles both cases, can change card at any time
  * misc. editing stylus
  * fix: misc. crashes
  * inline editing saves w/ user feedback!
  * moved ch.require-login to Auth.require-login
  * pass entire editor object
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * moved show-login-dialog to Auth.show-login-dialog
  * better lazy loading of complexify
  * total monthly cost now calculated based on subscriptions colun
  * add subscription_total stored procedure
  * wip payments, a subscription is now added subscriptions table when you buy something
  * removed handlers from pb-handlers.ls that had already been moved to auth-handlers.ls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in wip
  * Merge branch 'master' into auth
  * erge branch 'master' of github.com:khoerling/powerbulletin
  * stop when we've loaded all previous messages
  * stripe init script
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * form + inline saving working!
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * further streamlined ckeditor plugin
  * loading previous chat messages (wip)
  * inline ui for replies
  * auto focus first reply
  * don't send if message is blank or all whitespace
  * messing with stylus for chat.
  * gave a default width for embedded images
  * allow false values to be set in an UPDATE via thin-orm
  * fix: crash on cleanup
  * misc. footer style
  * editing working better & cleanup
  * fix: only update textarea when ckeditor data
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * misc. ui
  * footer rises after 2.5s on initial load
  * pager back to showing if >= 2 pages
  * move presentation concern into presentation layer
  * changed behavior of paginator to be empty unless pages > 1
  * since paginator is inline items in a div with auto height, it didn't need display:none, it dissapears all by itself
  * small refactor
  * only show pager when more than 1 page and cleanup
  * reply working & big cleanup
  * save button working!
  * user-friendly errors
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * cleaning up editing code, moving toward a ckeditor-unified strategy
  * some guards
  * + lazy load
  * open links in chat window in new page
  * sanize chat input
  * don't crash when there's no @post
  * universal PagerTron, deploy =D (look at footer)
  * ckeditor wip
  * posting tooltips & validations
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * layout ui ++ && cleanup
  * chat.load-more-messages (wip)
  * set data-message-id attr for both sender and receiver
  * pass on message id in chat messages
  * fix: a couple issues from domain -> subdomain and then some ...
  * sales page++
  * pulled out control style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reload all jade templates on -HUP, too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * started a resource for conversations
  * trap server.close errors and cb!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * one less div nested in output
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reuse the paginator component, but lazily initialize it also
  * faster watch
  * removed some console.logs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * persisting chat messages
  * allow mass assignment of locals to component
  * locking down more critical behavior of Component
  * whoops fix ngramming
  * make app/search.ls recognize page param
  * paginator in better shape now
  * took advantage of new behavior in component to shorten code
  * don't blowup with an exception, just silently ignore attach/detach unless @is-client
  * change step size in correct place this time lol
  * pass in correct step size, still brokenz, will get to the bottom
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + pbsave plugin for ckeditor!
  * search tweaks, paginator feels pretty good right now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix server-side renders
  * - save plugin
  * Merge branch 'master' into auth
  * provide window.siteName to Auth.jade
  * added siteName
  * pull in Auth Component style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui tweaks
  * included Auth component
  * factored out regexps so they could be shared between pb-handlers and auth-handlers
  * fckeditor + save plugin - about
  * use the routes from auth-handlers
  * lazy load complexify js and render Auth component in show-login-dialog
  * made Auth into a real Component
  * fix regression / tests
  * paginator is now rendering on client mutations only and i'm not sure why : \ but it works.. will figure out rest later wip
  * latest stylus
  * Merge branch 'master' into auth
  * add some more safety, so we can't set reactive functions and we will know what the problem is
  * go full hog reactive with paginator
  * whoops missed a small bit of cleanup
  * tweak Component so you can now specify locals _as_ reactive functions, thus reducing complexity and leveraging reactive programming, see Paginator for small example of this
  * latest tweaks, can now assign with local method, and there is now an init method which is for component init
  * fix a regression and tests
  * add auto-attach powers to Component, make paginator anchors mutannts
  * more tests
  * fix a bug in paginator, start writing unit tests to cover all these weird cases
  * shading ...
  * checkin Paginator wip
  * Paginator is somewhat correct now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * checkin paginator wip
  * don't output @ -- to much noise
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reorganized chat server code
  * manually reload socket.io on @init
  * pass conversation.id in message
  * re-balance common
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * force pb-worker-* to stop on ^C
  * added password strength meter
  * tag pages with classes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add Paginator work in progress
  * password show/hide toggle on register + choose password dialogs
  * register shows all errors + cleanup
  * killall -r pb-worker
  * Merge branch 'master' of github.com:khoerling/powerbulletin into preempt
  * Merge branch 'preempt' of github.com:khoerling/powerbulletin into preempt
  * preempted
  * moved fancybox css after head and further layout rice
  * preempted
  * pruned old on-personalize
  * left nav threading much cleaner
  * preempt main, wrap into ServerApp class
  * - nospawn
  * turn the Gruntfile from js to coffee
  * don't make watched tasks depend on watch
  * lazy load css, too!
  * lazy load js for loggin-in users and admin
  * + misc style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + sceditor (inline coming!)
  * fixed another join in posts-by-user
  * missed a spot
  * forgot to check this in; - instead of _
  * use - instead of _ in chat event names
  * db.posts-by-user was joining the wrong table in one query
  * cleaned out public/local
  * fix: race a couple conditions w/ History & click handlers
  * fix: guarantee only 1 browserify, even if multiple grunt procs
  * fix: no more corrupt browserify bundles
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * re-re-added interrupt:true
  * chat (work in progress)
  * fleshing out menu admin ideas ...
  * sharper common elements
  * left column admin no-longer resizable and then some
  * doh forgot the library
  * create pure wrapper for cc-validator-node
  * npm install cc-validator-node
  * add necessary ui fields to accept credit card details
  * doBuy('custom_domain') and doBuy('private_site') work based on db models, now to crack out on checkout process
  * add resources for products, only need show for now
  * add test routine to payments lib
  * forgot the notes i added to schema =D
  * two new tables, purchases and products
  * Revert "to be safe, lets pass the cookie only to the domain where it is needed, and avoid possibly leaking secrets to the wrong people"
  * to be safe, lets pass the cookie only to the domain where it is needed, and avoid possibly leaking secrets to the wrong people
  * menu admin beginnings
  * refactoring auth into component/
  * factored out auth routes into separate file
  * fix regular posting
  * update validations to not be retarded
  * plug security hole
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed it, but no admin access for /admin ??
  * tools menu sync'd with transient
  * @beppusan see if this fixes your security concern
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * payments api, it begins, mwa ha ha
  * consistent transient defaults from models to views
  * guard against transient logout
  * mutant now only marshals non-void values
  * fix: bail out on profile if none exists
  * first pass & literature to sales app
  * signature flair
  * fix: misc. crashes
  * npm install stripe
  * misc. style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + source flair
  * fix: break for /new editing (so history has time to update url)
  * r doesn't always exist
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * emit correct post count on thread-create and better error handling
  * allow non-transient users to post again
  * invites working!
  * + is-email
  * post.user_id XOR post.transient_owner
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * the button going beyond the left edge of the screen annoyed me
  * more fixups, one last one is eluding me (for reply ui)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * beginning of a reusable sql fragment generator for the transient_owner shim, i need to do about 4 more fixups but they can all share the same js string template
  * made scraper work again
  * whoops forgot image
  * added future owner default image, and remove extra / from user photo in threads
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * posts from future owner now show up in thread list, and has defaults for future owner name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added ability to choose a username after confirming invite
  * user_id is now nullable on posts
  * remove extra character that was typod
  * insta-site-creation w/ redirect works, now to hook up the transient_owner cookie with /auth/user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create general forum by default on site creation
  * i believe this will fix the gruntfile
  * - warning
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create-site procedure now works, can take a user_id or not, returns transient_owner identifier if no user_id passed in
  * misc. ++
  * improved error handling + re-sends invites if re-invited
  * name-exists proc takes email instead (+ refactor)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add transient_owner TEXT field, will store random hash identifying owner, if owner hash + site matches, then we auto-login them in as admin in /auth/user
  * use cookie in sales app, sales app is now pb.com instead of sales.pb.com
  * latest
  * live keyup availability check (red or green checkbox to verify)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * availability checker for sales
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * needed to contrain get-cols a bit more
  * moved specifically client functions outside of shared helpers
  * helper refactor
  * another pass on admin/invite, and then some!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added minimize && thinking about socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added send-message(ev) method
  * fit the textarea into chat box more snugly
  * fix: show correct tooltip even after error
  * ported what exists of Chat to new Component system
  * fix: global.
  * merging...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * stylus now on sales page, other tweaks, gruntfile fix?
  * this is why i dislike putting json in csv
  * notes for systematic refactor of main.ls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove unused file
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pages now single-column w/ transitions in & out
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a fixture for pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * set class to page
  * return of the interrupt
  * help cursor & moved layout bits there
  * silly matt, load your stylesheets always before your javascripts ; D
  * css loading superpowers
  * load up all js stuff properly, integrate layout.ls
  * create file which will keep track of remote js urls
  * latest tweaks
  * separate out loader component, hope to share layout.ls with it
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * pages route and mutant
  * page handler
  * more sales fuddling
  * updated Buy ParallaxButton and SalesApp to conform to new Component
  * configurable auto-render, dont auto-attach
  * update component tests
  * latest component lib with reactive integration and now need to setup children in constructor
  * some refactoring
  * make it so that children returns an object instead of a list for easier referenceability
  * allow specification of locals as 0-arity funs 'lazy vals'
  * make Component.ls compile with -k
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * rename SalesLayout -> SalesApp
  * working toward invites, need to auto create users next
  * refactored to use new email helper
  * bootstrapped SalesLayout and Sales components for sales app
  * oops forgot app/sales-app.ls
  * sales domain added
  * integrate attach into render phase
  * subsequent renders now work as expected (backed up with test)
  * render does not render children on first pass (instantation of child handles this)
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * parameterize on-click for ParallaxButton component
  * window.do-test demonstrates how a component can easily take-over an arbitrary selector (in this case 'body')
  * more polish, fix tests
  * major overhaul of Component, took suggestions from john, treat dom as first class and remove need for unique classes by scoping everything
  * added initial help/forgot to auth dialog
  * fix: production boots!
  * parallax button component works now, js and all
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * fix regression with Buy
  * fix regression with Component.ls
  * fix bin/diediedie
  * skip creating dom (optimization) unless mutate phase or children are defined
  * various tweaks
  * wrote test for nesting
  * refactor Component and update tests, pulled reactivity out, that can be a sub-class later, wanted to KISS for now
  * added pages table and removed trailing spaces
  * misc. ui++
  * fleshing out admin email invites
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored email into helpers, ready to use for admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * implemented chat.add-message and changed spacing between chat windows
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * now using site.current_domain for email from:
  * maintain a hash of chats and don't allow more than one to the same user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: only purge varnish if censor happened
  * censored posts retain permalinks, etc...
  * reorganize chat windows on close
  * fixed my .Chat prepending bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * john should be like butter now let me know
  * separated #chat_drawer from footer
  * fix: guard censor from crashing node if called multiple times
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more debounce
  * fix: sort media urls to top of site & forum summary
  * fix: using e.target instead of "this"
  * source maps only in dev mode
  * refactoring of jade bits, build jade with debugging in dev, compressed in production
  * move window.mutate into client-helpers, fix one last regression for browserify hopefully
  * - reduce the global headache by creating a module named client-helpers - fix regressions after browserify + grunt regressions - grunt works AMAZING now ; )
  * Gruntfile tweaks to watch components / be less annoying in dev mode
  * source maps / latest browserify / fixed merge regression
  * resolve merge conflict
  * misc. ui style
  * consistently default posts per page to 30
  * censored posts show up in profiles + new censor style
  * yay browserify works + we have source maps w00t
  * fix: don't crash if posts blank (guard blank ui input)
  * fix: don't crash if no varnish bans
  * start of invites admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Chat uses matt's components
  * update browserify
  * post owners can censor their own posts (and admins)
  * + require admin middleware
  * fix: re-enable submit button on success
  * summary model clean up, favoring media_url & starting to build homepage views
  * window.do-buy
  * build component jade templates, add to grunt, also start of 'Buy' component
  * - fix regression replace-html doesn't work quite right... - Component tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add Component library i've been hackin on, a HelloWorld example, and accompanying test framework
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. css
  * fix: user check
  * added aliases.config json field
  * redirect to homepage on logout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * facets feel pretty cool right now ; )
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * you now see live facet updates as you type, and they go away when they no longer provide any selection
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * laying out stronger data foundation for homepage & forum homepage
  * latest tweaks, update filters on every statechange since there is more going on now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum facet items now link to filtering on that facet
  * don't scroll when clicking footer
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Chat skeleton (wip)
  * commit wip of forum facets, need to switch to ids and map to forum name with hashmap (can be done server-side)
  * fix regression where replace-html was not being called when searching because not in scope
  * convenience script to reinit elastic from scratch
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * facet on forum title, wip, see SEARCH.TXT for example, will integrate with ui next
  * all mutant static using replace-html
  * fixed pagination math
  * reflect search in tittle
  * latest tweaks to search, fix some history regressions, add nice benchmarking if we wanna use it (in pb-mutants) only used in search mutant now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * homepage showing data with new, faster query
  * fix regression, search bar filled up again
  * fix regression
  * use raf only if mutant has split out prepare/draw phases .. if draw phase is too slow we get frame dropping
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made title and meta tags show up on static loads
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * page titles
  * disable form submissions until success or failure + tooltips
  * fix: really ban profile pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * search mutant is fully riced with raf, last bit to optimize is layout-static (split into two phases, first phase produces data, second phase consumes+updates dom)
  * testing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ban profile pages when posting
  * fixed 3rd party oauth logins
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed local user registration
  * add backwards compatible prepare/draw phases, existing mutants don't have to adopt it but can, renders longer than 16ms are errors on the console
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * try this keith
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * raf is now automatically used for render-mutant, while not anymore in the large case
  * use requestAnimationFrame polyfill with mutant, fix bug in mutant where we were running the mutant.run callback handler 3 times
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * spacing
  * first pass on re-thought homepage
  * remove console.debug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only render profile's left_container if not same profile
  * use generic surf data (should be set to forum's, profile's, etc...) instead of specific forum-id
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * let the existence of @top-threads decide whether we render the left-nav or not
  * removed pick function (not used anymore)
  * clear varnish after scraping
  * bumped media_url to 2,000 chars
  * partial for chat box
  * change argument order to any()
  * disable password reset input elements
  * finishing touches on forgot password flow
  * much better reliability with filters, can't rely on hints for now
  * more querystring beautification (no more lonely ?), hopefully fix bug where leftbar wasn't rendering at the right instances by using current instead of last hint
  * small performance tweak
  * cleanup code and make a little more readable, also keep bullshit out of the querystring (also fixes repeating = bug)
  * save and edit replace url instead of pushing (as they should) will get rid of dangling edit and new urls in history
  * fix initial pagelaod of /edit too (allow cookies)
  * fix: forgot hover/arrow
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * I forgot your password.
  * some visual tweaks for filters
  * can now reply directly from a search page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * decorate thread hits and comment hits
  * pager .current draggable now snaps
  * show all forums on forum_id filter
  * on enter change to search mode, but if on search already, soft submits can also send queries
  * hey /new called, and wanted its cookies back
  * hook up within in app/search
  * add ui side of time filter, need to tweak app/search now to receive within paramater
  * reset search state after leaving search mutant so filters don't come back from the dead
  * don't reload leftnav on search
  * various tweaks to search to allow empty querystrings (filters only) also notify user of overly-restrictive terms
  * make app/search aware of new querystring parameter forum_id, various other tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * beginning of left filter controls, reactive-style
  * + u.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * style back on all .close'ers
  * removed prelude from procs & profile page loading
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip search, searchopts passed all the way thru, one unified interface for realtime + frontend query
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot password part 1 of 2
  * searchopts working uniformly w/ notifications and frontend search
  * refactored save-stylus into model
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * run middleware correctly on /resources/*
  * always generate main.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * conditional cookie
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to call cb
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed main
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * updated main.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * relying on set-timeout to keep the right global visible
  * updated readme regarding firewall rules
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * automatically populate thin-orm via information_schema
  * broader hover region
  * downgraded console-trace
  * prelude working with new require \prelude-ls + beppuhack
  * updated cheerio, async, livescript, console-trace & express-resource
  * another pass on homepage, looking better and faster-er
  * cleaned up closers and search clears
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * setup thin-orm for some tables. mixed in to pg.procs for easy access
  * oops-- fixed homepage, too
  * fix: select active top & child-level main menu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ban varnish urls in admin when appropriate
  * added fields param to db.sub-posts-tree
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * guard against going beyond last page in pager.set-page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes close / admin overlap on search input
  * expose some pager functions for debugging
  * this is barely an orm so it's ok
  * hack fields onto top-posts-fun so that it propagates to sub-posts
  * fix nice scroll rail
  * trimming homepage
  * a bunch of layout ui fixes & improvements
  * make thread title show up in comment hits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * convenience for scraping a buttload
  * added mma.pb.com/site.css generated from fixtures
  * when mutating away from a search page, leave search channels
  * join search channel on initial pageload, work around raciness with reactive =D
  * scroll-to -> onclick-scroll-to
  * now scraping media_urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added media_url to posts
  * really fixed my regexes
  * bumped title length
  * ok yay, no keypress steals AND back/forward events exclusively are the only thing which will override the query box (that and fresh page loads)
  * slight regex changes
  * only show each 3rd-party auth on login if setup in admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added more rice to search, don't needlessly do dom update pushups if someone really smashes those forward/back buttons
  * sprinkle animations
  * improve nicescroll
  * prune unused code, slightly less frisky with soft searches
  * improve scraping so-as to remove annoying apple.png/droid.png which is littering my console ; )
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: syntax issue
  * yo search box.. lol give me back my capital letters
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * soup up search, doesn't steal keypresses anymore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass on domain-specific stylus
  * made db.usr() able to query for users by email
  * unarranged user fixtures to remove spaces
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added aliases.forgot and updated fixtures
  * .scroll-to-top -> onclick-scroll-top
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: guest users have socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only personalized routes need a giant stack of cookie middleware ; )
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unicode support in post slugs
  * fix: nicescroll rails stay in place
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * html symbols back and no-longer pulling jsdom in runtime
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * UTF-8!
  * cheerio working on all mutants
  * + cheerio
  * cheerio set to default & working on forum mutant
  * shrink browserify bundle on client
  * scrollable tweaks and then some ...
  * beginnings of site-specific stylus for admin
  * native scrollbar-less, hardware-accel scrolling for left nav
  * main menu, homepage & layout ui cleanup
  * conditionally profile:  export NODE_PROFILE=1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * npm install git://github.com/bnoordhuis/node-profiler.git
  * latest prof changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass at stored procs for private messaging
  * tools drops down with better mousing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * search ui++
  * npm install git://github.com/sidorares/node-tick.git
  * profiling in dev mode, and script to parse v8.log
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: paginator tooltip should always appear
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reactive.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added mon do die, so:  ./bin/diediedie; ./bin/create-pg && ./bin/launch
  * extra validation for email & user name on register
  * added the concept of conversations
  * npm install git://github.com/mattbaker/Reactive.js.git
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tables for private messaging support
  * shrink css bomb
  * tooltips on login/register!
  * show-tooltip helper
  * fix: really use posts-per-page site config
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added .tooltip.right to paginator indicating active page
  * admin authorization -> domains
  * don't forget to do simple optimizations for forum <-> non-forum surf transitions
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * removed a console.warn
  * reduced # of prod workers to 1
  * added private key to pem for automatic load
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * haproxy production hooked up with prod.pem
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * minimize async.auto tasks for inter-@forum surf requests
  * added tooltip + save indication to admin
  * guard post edit for ownership
  * guard admin for domain ownership
  * beginning of search shim, has an option for streaming which will hook right in with search-notifier
  * fix logic bug in varnish ; )
  * small correction in anal-ness for regexp
  * don't depersonalize urls ending in /new or /edit, don't cache 404's or redirects
  * + ssl bundle
  * oops, didn't mean to prune this
  * make indexer more informative on console about init/startup, tweak batch-size up some, make idle wait a bit longer
  * add script to tail postgresql log + indexer and notifier daemons in one console
  * remove internal header now that things are working gravy
  * start of a tooltip and more
  * keeping cacheUrl only
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic surf data minimization for non-forum mutants
  * fix: twitterConsumerValue -> twitterConsumerSecret
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got it!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: syntax issue
  * removing surf data minimzation from server-side; planning to move to client
  * surf data minimization functions (wip)
  * fix:  site -> domain
  * admin authorizaion saves & defaults
  * + comma key for triggering search
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more admin style
  * admin-general reads & saves!
  * admin -> admin-general
  * fix broken parse function; needed parens
  * added forum-uri to metadata returned from parse
  * w00t, add fields to search, give post fancy view to search hits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add debug logic to figure out where human readable time is brokenb
  * part of merge?
  * merged etag headers
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * scrolling left nav. again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * purge forum page on post update
  * initial scrollable + mousewheel & mods.
  * fix: don't crash when personalizing mutant
  * entire thread clickable on left content
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * prefill posts-per-page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * invalidate threads when creating sub-posts
  * abbreviated created fields
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * s/update-site/site-update/
  * time based caching for frontpage and forum urls
  * cache homepage for 60s in production
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * the big caching patch, wip need to add some more invalidations so we don't end up with stale content
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * local login needs to lazy load passport, too
  * added posts.is_locked and posts.is_sticky to schema
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * can has touch this?
  * provide default avatars; still need to dig out avatar info from 3rd party if available
  * passport lookup is now lazy
  * replace ALL the phone icons
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * do a better job of removing those annoying iphone/android icons for phone posts
  * hammer time
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * if there is no page var, provide a default internal dom for #paginator
  * fix: homepage data
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * typo postsPerPage
  * highligt the right h3
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. profile & homepage enhancements!
  * new tools menu
  * another pass at /admin
  * automagically expands left_container if collapsed when mutating into /admin
  * fix: oops, need to be more specific  :)
  * site.config.posts-per-page
  * fix: show avatar on profile replies
  * domain -> current_domain
  * fixed domain-related procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * put keys in domains.config instead of site.config
  * script for modifying a row in the domains table (with config support)
  * added domain-by-id and domain-update
  * added .onshiftenter-submit and mutant-specific .onclick-submit handlers
  * Merge branch 'master' into domains
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * let /socket.io give us cookies; only let /auth set cookies
  * show created date on wide left nav & only hover for narrow
  * intelligent logout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: mutant callsback on-personalize
  * more layout depersonalization for admin, login, logout & profile
  * removed --domain option from bin/site-config
  * added domains.config and updated fixtures
  * surf data minimization (work in progress)
  * guard stored procs
  * fix: homepage sorting crash
  * auth saving wip
  * guards
  * posting ui++
  * hacking on admin
  * new tools menu: admin, profile, logout and layout improvements
  * fancybox & login++
  * fleshing out /admin/authorization
  * dropping another ui bomb
  * added style for blockquotes
  * experiment with making thread-create an event on $ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * task differencing work in progress
  * same thing for non-prod config
  * remove dead/nonworking code, should be fine without
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * various varnish tweaks + gzip fixed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * paginator animates show & hide in sync with left_container
  * refactored handle into layout and some nav style
  * fix: resizable must run on initial load
  * minor cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hide first post on pages > 1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: post_edit -> post-edit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: env for search
  * refactor: underscores to dashes in filenames
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ignore user images
  * res.vars refactor
  * + admin_nav
  * ignore public/images/user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * moved verify to /auth (for depersonalization)
  * beginnings of /admin
  * don't need fdoc.pages anymore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * /user/:name/avatar changed to /resources/users/:id/avatar
  * procs.usr can now find users by id, too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added admin to depersonalize
  * secure client cookie
  * fix: keep passport session cookie
  * simplify depersonalize logic
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * pass NODE_ENV thru sudo
  * whoops, correct condition for not installing elasticsearch twice
  * don't depersonalize urls matching ^/resources
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * increase debug-info and reap intervals, remove TODO which is complete from comments
  * misc. style boost
  * working on reply dialog and then some...
  * fix: more reliable order
  * merged!
  * experimenting with jcrop
  * added jquery.Jcrop plugin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed behavior of cancel button in edit view
  * add logic in varnish to depersonalize all cdn urls regardless of url
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * randomize search-notifier work interval, DEPERSONALIZE all but ^/auth and ^/admin in varnish
  * only set up the uploader on YOUR profile
  * add title of last post to realtime widget
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in search wip, now shows a div which updates saying 'new search results'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * html5uploader from profile pics
  * added change_avatar(usr, path)
  * installed mkdirp
  * try to fix keiths bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * realtime search hit updates WIP -- update/delete side handled by existing system when implemented, just need to unify search interface now between socket.io and frontend ajax
  * added tab to search blacklist
  * really run on-personalize
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * banning keycode 87 from initiating search
  * personalize static loads
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * subtle pager theme & handle
  * fixed bug where disconnecting would not remove one from a room
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reaping pollers works
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * w00t, rooms work without socket.io-announce
  * dash vs camelCase
  * profile page+++
  * fix: left-nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * s/pageCount/pagesCount/ typo fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * deal with window resizes correctly in pager
  * whitespace
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added jquery html5 uploader plugin
  * moved the logic for showing pager controls to one function
  * trying to fix production
  * invert my logic
  * merged!
  * set-page can optionally not manipulate history
  * added forum + user context to profile pages like reddit
  * parse-int to the rescue
  * fixing more pager bugs
  * fixing many pager bugs
  * previous and next page via arrows; bare minimum seo
  * if the surf request failed, bail out
  * hide footer completely by default
  * fix: set min-width higher for left_content
  * default left_content to wide view + simplified cookie
  * next-mutant & prev-mutant refactor + search history
  * after creating a new thread, mutate to it
  * draggable page indicator
  * default font to sans-serif (just in case nothing else matches)
  * misc. fixes
  * search ui++ and then some
  * paginator only shows when there's more than 1 page (hides by default)
  * more login and layout stylus
  * human time has bolded numbers
  * oops, also mutate when clicking for context thread on profile
  * possible to reply on profile & forum pages now!
  * paginator accomodates triple digits vertically & sped up main menu animations
  * added enter to search ban list
  * showing thread context on profile page among other enhancements
  * another paginator/left-nav ui pass
  * added spacebar to blacklist
  * fix:  "surfData is not defined"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * auth + paginator style
  * slide in new posts + moved form submit into helpers
  * more accurate math for pager click behavior
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tune up caching for production on static resources to a 1-year ttl (we can depend on the cache getting blown on each deploy)
  * our not-so-graceful shutdown (force shutdown after 5s)
  * made user profile paginate
  * added db.posts-by-user-pages-count and made db.posts-by-user page aware
  * warn instead of log so access log is not polluted
  * merge conflict resolution
  * take advantage of jquerys automatic normalization with it.which
  * timing + guard
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. pager + main menu ui
  * scroll to active thread in left nav on initial load
  * re-enabled key logging for when search is triggered
  * bi-directional communication can't be done thru client :\ not sure why.. but with server-side + clientside we are complete without announce
  * turn off immediate mode (so we can see benchmarks of how long routes take)
  * tune up the thresholds in spinner slightly, also make slight tweak to algorithm to make it more correct
  * make bin/diediedie more frisky, mon-ify indexer and search-notifier
  * add mon recipe
  * create wrapper to daemonize search notifier
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * install socket.io-client
  * wip query poller, requires socket io client
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * prevent double-posting of the original post
  * removed even/odd in jade
  * changed us into super users
  * use @forum-id instead of window.active-forum-id
  * only pager.set-page if we have a valid window.page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * merged!
  * fix: mutate left container by default
  * cursor pointer for #paginator
  * moved #paginator and added #left_container
  * initialize pager on forum load
  * require pager
  * hook up History.push-state into pager
  * Merge branch 'prod'
  * massive style bomb, working on homepage
  * added _post_profile partial & consolidated all profile photos
  * Pager class
  * fix: homepage orderer shows back up after mutating away
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * homepage / forum homepage switch between resize & not
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * spinner tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add socket.io-announce to repl
  * Merge branch 'master' into prod
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix fancybox flash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * waiting cursor override anchors etc so people know mutation is taking place
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added reset dialog for beppu
  * re-align edit dialog (centered)
  * loading cursor yay baby
  * re-align edit dialog (centered)
  * raise the rate-limit threshold
  * continuous stager now pushes to prod
  * test again
  * test
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check for development mode more accurately
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added access_log for development
  * cssmin breaks stuff
  * fix:  now able to fresh-load edit urls
  * megamenu++
  * inject.js has to be http
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wrong cdn urls for prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * really hide paginator
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * changes to help make it work on prod
  * hide paginator
  * mutant states simplified (no longer tracking last in separate variables)
  * thx to beppusan the great, we now have a namespace for procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove host vars, add cache domains to static config
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * replaced db.forums() with db.forum-summary()
  * found stray hardcoded site-id; fixed with 2 joins
  * user pb in home /pb
  * resolved merge conflicts
  * style bomb, mostly addresses posts & child posts
  * fix: main menu active
  * onload-layout-resizable factored into layout itself
  * fix:  oops, default to not refresh left_nav
  * added surfing data to mutant & hooked up to forum mutant
  * .? -> ?
  * responsive++ among other spacing/leading tweaks
  * don't kill indexer on diediedie
  * first round at a megamenu and also more crisp theme
  * global helpers in repl
  * initial forum homepage view and then some
  * responsive js layout + breadcrumb
  * misc. css for post head & title leading
  * + responsive.styl & wide nav view
  * posts structure+style +++
  * edit/reply can happen simultaneously
  * show/hide #order for specific mutants
  * better handle forum backgrounds
  * edit post working _much_ better
  * first post aligned with left nav
  * main menu always clickable as z-index on submenu falls behind
  * last-mutator on window + cleanup to use it
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make db.post return tags also
  * fixed comments for add_tags and add_tags_to_post
  * associate hashtags to posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * symlinked prelude.js into plv8_modules/ directory
  * refactor with folds
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added db.add-tags(tags) and db.add-tags-to-post(post-id, tags)
  * search on blacklist (since we might have unicode) + re-org
  * _surf=window.mutator
  * oops, really ignore arrows
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ignore non-printable and arrow keys for search purposes
  * layout+++ and cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only react to printable characters and backspace onkeyup
  * new thread cancel works & cleaner layout
  * when initializing elastic, initialize setting for pb (atempt to)
  * install superagent
  * fix:  real-time threads working in nav again  :)
  * style bomb
  * search wip, ellipse sidebar with css, resizing is a bit funky on mutation...
  * show hits in left pane too.. needs some styling love bad
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip, we now have custom search events which couple together keypresses + surfing for instant search
  * use varchar(16) for posts.ip instead of inet to try to prevent crashing
  * suppress output of git command
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * prevent add-post from crashing due to invalid ip addresses
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create 'search' event which is for now just mapped to keyup of the query box, it also passes the search params as part of the event args
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * another thing I forgot to check in
  * save the ip of the user who created the post
  * added null ips to all fixture posts
  * fix:  reply (post_edit)
  * added posts.id
  * fix emoticons when cache_url is overridden
  * homepage_forums takes 2 params now
  * + cleanup
  * refresh only when order changes and more efficient menu redraw for layout-static
  * run as normal user; will sudo for you when needed
  * forgot to check this in
  * security fix:  removed site tokens, etc... from surf urls
  * made db.homepage-forums take a sort order
  * moved html around for order controls
  * style for order control
  * added app/views/order_control.jade to jade.templates
  * order control template for the homepage
  * missed a spot
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleaned up & refactored all jade views, making partials out of everything and pulling them in separately:  partials denoted with _ prefix and everything that gets blasted by mutant + layouts without prefix
  * a script to launch everything
  * rebalance profile seo & add style
  * fix footer & left-column sizing
  * repl has shared + helpers merged into global
  * + shared_helpers.add-commas
  * homepage center, spaced & sorting nearby pagination
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resizing, breadcrumbs, cleanup & refactor states -> mutants for stylus
  * ngramming WIP
  * rudimentary styling and debugging
  * merge conflict
  * + merged beppu's changes & auth.jade
  * massive stylus refactor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * search interface returns json for no
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't crash when you don't have a profile photo
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix small indentation inconsistency
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Revert "installed simplesets"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * the big fucking elasticsearch + indexing commit
  * make .avatar scale to left nav width
  * consistent main menu behavior
  * install elastical@0.0.11
  * added data-user-id attribute to div.profile
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * upgrade sync
  * distinguish between local and remote profile photos
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove archived field (unused) .. add index_dirty in its place
  * show posts by user in profile
  * adds container to profile for hiding content
  * force redraw of forum left nav
  * properly guard against installing elasticsearch twice
  * dropdown menus should be on top of left nav
  * installed simplesets
  * collapsed handle moves far out of the way
  * left nav is now below the header
  * fix refactor bug & re-aligned/spaced resizable containers
  * yearg jade
  * Merge branch 'before-node-upgrade'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * display info for profile in profile 'nav'
  * added .resizable class to posts.jade
  * load more data for profiles
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hack to make browserify now work on latest nodejs etc
  * use .resizable instead of .forum to be more general; added layout-on-load(window)
  * + bitmap for sceditor
  * added views/posts_by_user.jade
  * TODO: capture profile.photo if available
  * added post_count to usr()
  * sceditor base css+theme
  * css cleanup
  * sceditor saving and looking good!
  * make usr procedure return more info
  * allow sp.user_photo to come from other domain in post
  * db.posts-by-user needs to be aware of site
  * less noisy logging of metatdata
  * really fix jsdom
  * update jsdom
  * upgrade to jsdom to 0.5.6
  * update geoip and bcrypt
  * console.log less metadata
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * nodejs update to 0.10.3, add elasticsearch recipe also
  * make . a forbidden character in forum urls
  * set-online-user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: switch and focus correct dialog for 3rd-party auth
  * io_server handshake
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.posts-by-user user-id
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * grab git changeset more reliably
  * + notice for graceful shutdown
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * - google font
  * added basics of scedit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use surfing for pagination
  * fix pagination to use mutant stuff
  * fix scroll-to-top & default to no search + expanded nav
  * add fixtures to expose pagination
  * only include said page, don't list previous pages (was for infinity)
  * + staging & personal testing aliaes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added domains table; site has-many domains
  * try setting longer timeouts
  * - require https (handled upstream in varnish)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix bug, one test now passes again
  * more css refactor
  * remove infinity, fixup testing
  * breadcrumb n-depth -- closes #17
  * only load test swarm+mocha+chai in dev & staging
  * standardize on jquery-1.9.1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made mutant links to user profiles
  * minor: changed param name for transition fn
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * massive css refactor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix css formatting for mocha =D
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * small api change in fsm; decided against varargs; just give me an array of inputs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add a test for mutating from homepage to forum
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * test push
  * fix bug where forum wasn't loading when a user isn't logged in
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fully configurable and overridable cdn urls
  * local settings were not overriding properly
  * allow config/local.json to override settings (not in version control)
  * accidentally checked in some debug code
  * point to correct injection url
  * make testing actually work (before it was not waiting for tasks to complete)
  * give mocha nice output for test swarm
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tests reliable / work now / muahhahahahahahahaha / and output is nice too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed post count issue in top-threads (i think)
  * subpost -> post refactor
  * make is-editing use the state machine
  * sh = shared_helpers; pbh = pb_helpers
  * parseInt the post id for the edit state
  * added socket.io to scraper for fun
  * removed stray console.warn
  * use fsm to make guards more precise; removed regexes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * commented out fsm.example
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * install mocha and chai
  * inline mocha tests (integration hack for browserswarm) in dev mode using mocha and chai (pass ?test=1 to url)
  * thread-permalink part may be string (not just number)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more metadata returned from furl.parse path
  * + add personalization to edit
  * comments working on parent + sub
  * provide forum_urls state machine and helpers as 'furl' in the repl
  * state machine for parsing forum urls with examples at bottom
  * fsm = finite state machine
  * guards for login/logout
  * + jessee user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * snap-scroll to newly created post
  * the light fix
  * Revert "unbork create-pg"
  * unbork create-pg
  * strings in pg should be utf-8
  * closer to being able to respond to top level post all the time
  * fixed create thread
  * realtime thread post count & cleanup!
  * margin'd comment body
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * monster update for realtime post reply & edit
  * css hackery to be able to hover over last post (for the case when we only have one infinity page)
  * got rid of console.logs
  * window.is-editing-regexp was not available on server
  * TODO - be more specific
  * realtime thread impressions
  * can view threads with 'new' in title again
  * layout+++
  * fix url popup for 3rd party auth
  * accidentally broke graceful-shutdown
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * I think app.close() may be deprecated, because it crashes
  * neater formatting of error message + stack trace + logged in user name if available
  * make /hello crash on purpose
  * fixed homepage template to show post.html
  * wip got mocha working (install mocha globally with -g on mac os x)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tests with selenium wip+soda wip
  * body -> html (unescaped)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unsilence our error handler
  * + hello
  * really strip leading / after form cancel/save
  * dimensionsoftware.com -> beta.
  * thread update via socket.io (very rough)
  * left nav updated when new thread created
  * db.post() returns more data
  * fix duplicates bug on threads view
  * beginning of socket.io for creating threads
  * change default top-thread sort to recent
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use post.html instead of post.body
  * added comment to add_post()
  * fixes for redis launch & window. scope in layout
  * flat parent threads
  * use redis store for socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * installed socket.io-announce
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * lean refactor for client/shared_helpers
  * add bin/launch-redis
  * left-padding on nav should be consistent through refresh & mutants
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * install soda
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored general code from entry into layout.ls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add script ot launch selenium, make selenium recipe require java 7
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix for .forum container
  * remove duplicate header since both haproxy and varnish set it (but only on haproxy side when tunneling thru it, varnish will still set header correctly if access directly)
  * scrolling behavior fully restored
  * breadcrumb and posts coming together
  * create thread working!
  * fixed off-by-twenty
  * footer++
  * initial mutant scroll-to-top smoother
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * new flush footer layout
  * load site based on damain instead of user.site_id
  * added postfix to chef recipe
  * fix merge conflict
  * admin wip, need to fix left padding for div #main_content
  * more add post wip
  * only scroll if page > 1 & hello using handler
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added validation dialog and then some for email activation
  * send empty errors
  * automagic login after verification
  * don't automatically login after successful registration
  * user verification route
  * added proc verify_user(site_id, verify_string)
  * fix: off-by-one
  * regex out iphone and android icons
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * always use error handler
  * fix missing info for toplevel post
  * guard when page has no pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix 404 case -- 404 only if a page > 1 has no children, page 1 is allowed to have no children
  * hopefully, edit-post and add-post still work
  * added functions h.hashtags, h.attags, h.html
  * make scraper able to pull more than 1 page of a thread
  * default to pb database in a safer way
  * added posts.html field
  * installed bbcode
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay bug is fixed, its a bit jumpy, but state-restoral is bueno
  * wip scroll to correct page when statically pointed to ?page=3 for instance, still bug where paginator is calculating page incorrectly
  * more realistic buttons
  * guard on no user
  * jump-to-infinite-scroll-point-by-page ; )
  * whoops fix bug
  * also update personalization for posts (ie add edit button) when infinity loads items
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * update presence when you scroll
  * more left nav finesse
  * res.json err in express/development
  * z-index bump
  * single post edit/multiple reply comments open at once
  * reply & edit working better (can have multiple replies, etc...)
  * adds db.owns-post + securely guards /forum/edit
  * default to pb db
  * refactored reply (comments) to use general post functions & jade
  * show active thread on left-nav
  * nav width more accurate on narrow/wide classes
  * + uglify
  * grunt now re-browserifies jade on change
  * move multi-domain stuff out of main and completely into multi-domain middleware
  * socket.emit \online-now on mutate
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleanup
  * don't fail when $NODE_ENV is undefined
  * added online-now message to socket.io server
  * moved users.rights to auths.rights
  * don't fail when $NODE_ENV is undefined
  * add new topic post wip
  * fix: edit working again ++
  * fixes:  left nav .wide class & ./bin/powerbulletin env missing case
  * pimped out breadcrumb & main menu
  * speed up provisioning by skipping ri/rdoc, fix typo in production json config, add user 'powerbulletin' as part of chef recip
  * oops needed one more tweak to point haproxy to the correct production endpoint
  * fix bug in both varnish and haproxy launch scripts where they weren't using the env var properly
  * prod conf for haproxy
  * beginning to verify edits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove noise
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add aliases.verify upon registration
  * made auth available in repl
  * added aliases.verify and aliases.verified
  * added aliases.verify and proc alias_by_verify()
  * toggle .online class on .profile.photo
  * added animation to .online
  * paginator only shows if > 1 page & re-pulled in helpers for mutants
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * paginator guards & some style
  * .online css class to show who is online
  * fix: destructure crash now graceful
  * only show title if top-level thread
  * fix runtime error
  * nav has photo and wide-view default
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: removed space from default input
  * breadcrumb working again!
  * function for generating registration verification string
  * common widgets++
  * paginator follows current page
  * fix merge conflict
  * software, shits hard
  * start of /new editable
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made /:forum work again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in wip paginator.. trying to detect visibility of pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * beginnings of a registration email
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic paginator control
  * fix: cancel working again on edit posts
  * fix cache_url thingy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make esc keep work when focused on input boxes for login box
  * entire edit cycle complete without surfing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ok yay we have infinity scroll with templates
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * force reconnect socket.io after login
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip moving sub_post into its own jade partial, also split out mixins for reuse
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only load the right amount of pages, not into infinity
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic per-site presence
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more infinity tweaks
  * adds pb_helpers for shared entry & mutant code + factors out post editing to be more efficient
  * re-aligned menus & colors
  * added no-surf to mutant
  * sharper ui, common controls and added shrink animation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * local passwords now hashed with bcrypt
  * don't crash when user is not found
  * installed bcrypt (compiled module)
  * bug fix: responsive nav
  * comment out noise in serialize-user and deserialize-user
  * socket.io knows who you're logged in as
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * responsive left nav
  * add back part i needed
  * Revert "you are allowed to be a guest again! (bugfix) + wip all_sub_post_ids"
  * you are allowed to be a guest again! (bugfix) + wip all_sub_post_ids
  * posts edit and validate!
  * start segment at correct spot
  * tweak http-no-delay and forceclose accordingly
  * semantic change to haproxy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * socketio tweaks for haproxy
  * more on post saves, using generic .ajax form submit too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * configure websockets + socket.io for pipe mode
  * notes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * working to edit posts
  * basic socket.io setup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * posts/show resource (for editing)
  * installed socket.io
  * oops-syntax error fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * slimmed db menu
  * fix keiths bugs, re-init listview after mutation
  * dont rate limit in production, be more frisky, and finally lets not hardcode what we are pulling in
  * fix active-post-id
  * infinity dump the pages into the dom .. the live data in chunks of 5 top-level posts
  * 404 when on an invalid page, allow pagination of thread view (aka sub-post view)
  * fixed bug where subpost times were not being live updated
  * properly identify end of posts which can have more loaded, next need to add ref point for start of infinite load
  * improve performance, fix lazy init
  * load before they get to the end of the scroll, NEVER SCROLL TO THE END.. unless that is you are at the end of the forum
  * lost in merge
  * adds user photos
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed breadcrumb link
  * resources -> pb_resources
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * photo placeholder and misc.
  * refactor:  moved pb specifics to pb_, paving way for beer_, etc...
  * .editing class for posts & subposts (no longer cuts off inputs)
  * comments more obvious
  * register++ and working on main menu + breadcrumb
  * installed nodemailer
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * chef recipe to install selenium + soda
  * forgot to check in passport-google-oauth
  * change auths.id to decimal so google.user.id can fit
  * work in progress on google oauth2 login/registration
  * /auth/user shouldn't send an object containing sensitive auths info
  * automagically login after local registration
  * unique_name needed a site_id
  * added stored proc register_local_user
  * be more careful when blanking out input vals
  * proc for seeing if name already exists
  * local registration; could use more validation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip first mocha tests! bin/test
  * filled in @register route
  * wip of 'mocha-phantomjs tests/test1.html'
  * limit to 10 toplevel and 10 comments on toplevel posts
  * scroll to edit post position or top
  * permalink mutant
  * playing with breadcrumb position
  * isolated 'at bottom of scrolled window' event
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * put lodash in browserify bundle
  * added tags and tags_posts tables
  * suggest alternate alias names
  * auto close fancybox & -cl
  * adds correct create thread link
  * stubbed out /user/:name (user profiles)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * children posts & misc. stylus
  * generic form submit (using $.post now) & linked up to ui
  * 404 censored posts
  * gracefully handle the case where a  post is censored from the forum
  * reload on logout
  * no refresh needed on login anymore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * propagated site_id up the call stack
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * using on-personalize to properly bring out edit dialog
  * fix bug in children nesting on forum page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix bug in jade
  * u.sub-posts(site-id, post-id, limit, offset) // was just post-id before
  * fixes a couple ui issues and adds flush left nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix jade template for logged out (guest) users
  * run site-config outside of the loop
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * facebook and twitter keys for mma.pb.com
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add infinity to js sources
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * node 0.8.19 to 0.8.22
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * redis recipe with latest redis
  * main menu working better
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc.
  * more auth schtuff
  * default fake keys to prevent crash
  * twitter and google auth (untested)
  * using backcall
  * fix for popping up submenu when main menu is expanded in search mode
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * minor changes
  * utility script for changing a site's config
  * added and updated site related procedures
  * start of register function
  * added path to cookie
  * more transit embellishments
  * removed some console.warns
  * added sites.config for site-specific configuration
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added load-ui animations for smoother initial build-in and improved others
  * change username
  * mutate again.
  * moderation w00
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * WIP censorship ; )
  * facebook login/registration ++
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * css transitions for censor
  * bring in jquery transit 0.9.9
  * rights
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't crash due to not having rights
  * fix for .searching .submenu top
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * post censorship minus actual change of listing order
  * mark active subforum in main menu & only mutate left nav on subforum change
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more rice, use one script tag for marshalling
  * new and improved find_or_create_user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't crash onUnload
  * procedure for moderation 'censor;
  * fixture encoding errors fixed
  * super user privs for all the l33t guys in fixtures, add documentation for rights
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add rights
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored extra sorting functions out & natural default sort order
  * Revert "added auths.x_id which is a user_id from (facebook|google|twitter)"
  * spacing & leading on posts
  * finesse to login/forgot/choose username dialog and posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix thread page and improve error reporting for procedures when they are called with incorrect arity
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added "choose-username" dialog for beppusan and working on tumblr-style homepage
  * added auths.x_id which is a user_id from (facebook|google|twitter)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default sort is popular
  * working on nav & subpost
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a bunch of refuctoring to support different sorts
  * temporarily stubbed so it won't crash
  * work in progress on facebook auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * move mutant bits to layout instead of entry (also user auth which is a prereq for mutant.run)
  * mutants.js -> templates.js, removed from git, etc...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * automatically add _iso in addition to _human for adding dates, this way its easier to embed in data-time
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes main menu padding
  * update time only every 30 seconds
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resolved merge for real
  * - powerbulletin*.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a little refactoring
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added forgot dialog and some other goodies to login
  * realtime clientside time counting
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * login dialog and layout.css refactored to theme
  * partial application baby
  * good stopping point
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * halfway thru cleanup of doc generation, just use sql unless there is a good reason not to for now ; ) main menu is the only common item i can think of to be cached so far
  * combined configs.
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resize working again
  * custom error pages for varnish and haproxy
  * better crash prevention
  * update thread views on every load
  * add_thread_impression() to increment views
  * fixed fixtures to have default view counts
  * posts.views (for number of thread views)
  * killed dead code
  * added human readable dates to posts and nav
  * only redraw left nav on initial mutation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made it so that left nav doesn't change when mutating (hacky)
  * added username and post_count to thread mixin in left nav
  * added post_count to top-posts-{recent,active}
  * fix .advanced
  * improvements to inline editing & search filter ui
  * moderations added to schmea w/ fixtures .. also had to +e to get create-pg to work -- strange
  * latest tweaks, i had fudged up the varnish so now its fixed again, we need to implement nocache cookie for logged in users
  * varnish now has a white list for stripping cookies, looks for nocache cookie or for cdn domain urls
  * uri returns properly now from add_post, fixed reply dialog (was broken)
  * who keeps adding these to git lol
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * edit-in-place w/ jade & mutant pattern more fleshed out
  * add schema for moderations, create procedure for archive_post
  * fix merge conflict
  * add and use archive column for posts, actually remove the files from version control (bundled js files)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip inline /new/:id post edit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix uniqueness constraint so it actually works for uris, change add-post to try the pretty uri first and then fail back to the unique one
  * removed powerbulletin bundles from git & updated ignore
  * invalidate forum, some api safety netting for varnish init
  * convert add post to fancybox (easy) for now so I can actually use it
  * don't clip the last threads
  * remember better + using document delegate so handler isn't "lost in mutation" :P
  * handle collapses/expands nav
  * readying for beer. and additional sites wishing to use a mutant-powered layout
  * don't crash when cookie doesn't exist
  * added jquery.cookie (forgot to check in?)
  * ui auto saves & loads state across browser reloads!
  * lighter fancybox and cleaning up posts/subpost
  * expanded & scrolled states re-aligned
  * breadcrumbs in the right place; separated post & subpost + more style
  * kill with a whisper
  * Revert "updated geoip"
  * updated geoip
  * create abstraction where we hand cache.invalidate-forum an id and it does the rest
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactor one small part of protocol that was not documented (extra newline)... works better now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * left nav resize applies & cleansup with mutant states
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default callback for varnish command
  * letting content break subposts and snapping it together
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * login & nav ui ++
  * stick the body on that callback too
  * a few more tweaks, be less greedy with cpu
  * w00t we got varnish native wire protocol now for admin interface in pure nodez
  * purge varnish script (without restarting varnish)
  * graceful shutdown to avoid malformed bodies with 200 responses
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * small refactor in vcl
  * scrolling works better & colors
  * misc style
  * loads local head.js in non production + mutant refactor
  * only use minified powerbulletin bundle in production
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only kick off onPersonalize if user obj is not null
  * race fixed, yay
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a bit more
  * wip
  * wip
  * personalization in user urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * links up login popup, css & the resizeable left nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * simple css
  * merge conflict
  * onPersonalize baby
  * make html in body show up again
  * nested and toplevel subposts oh-my
  * fix bug in reply where it wasn't going to the right div
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * return uri instead of slug from add-post
  * working breadcrumbs and then some
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * merge
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add toplevel title and body to thread page
  * made reply-ui show up in the right place
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of infinite nesting of sub-post urls
  * davesan's password is 'davesan'
  * require-login should wait until the last possible moment (so this was too early)
  * added a require-login function
  * whoops, use site_id not id
  * associate added posts with currently logged in user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * allow cookies thru to resources urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * single quotes
  * merge conflict
  * various refactoring, + move threads_recent into its own doc that can be reused everywhere
  * killall before relaunching
  * shake fancybox on failed login
  * css3 shake animation - .shake
  * hooked up login form
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * icons for 3rd party auth
  * login form
  * window.user available via entry in client-land, looks at passport info from cookie on serverside at /auth/user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * indent .children
  * checking pb changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * append reply ui more carefully
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * strip cookies like a madman
  * natural order for threads
  * resolved conflicts
  * use the right mixin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * varnish tweaks for stripping all cookies from most urls
  * grab bag of changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * recursively display posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactor varnish, fixed silly issue with not receiving ssl header
  * reply ui (basic hacky)
  * forceclose for haproxy
  * add threads now works from thread view
  * wip
  * task varnish with redirecting non-homepage urls that end with / to the non-/ ending version
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay show toplevel threads on thread doc / thread view
  * force post.build_docs to false all the time
  * made posts show up again
  * refer to sub-posts as 'sub-posts' for thread view
  * rename post-doc to thread-doc
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add debug route for sub-posts tree
  * build_docs key set to false leaves stale docs
  * maybe an improvement
  * fixed scraper (i think)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * conflict
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * guarded unload and misc.
  * redirect only on GET or HEAD requests so we don't do something silly (like redirect on a POST)
  * limit recurse depth to 3 by default for sub-posts-tree
  * and were back with super paranoid security, redirect loop gone, ALWAYS SSL!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * haproxy + ssl is in, now to fix this gnarly redirect loop in varnish
  * shared cache domain for all vhosts
  * add guard to recipe so it doesn't repeat
  * recipe for haproxy
  * stunnel works woo, and varnish forces https
  * stunnel config and launch script created, also dev cert
  * varnish config syntax errors fixed, slight refactor
  * force ssl in varnish + added a bunch of security headers
  * fix bug where add_post was crashing postgresql
  * alot of refactoring for add_post, we are now able to add posts contextually from within its parent post (to create sub threads)
  * tweak UNIQUE constraints so that slugs are bulletproof (guaranteed unique within siblings)
  * woot can surf now to posts and forums with new /t/ scheme, also updated uri generation
  * small refacgtor
  * latest wip, post doc (for sub posts / thread view)
  * bugfix add posts work again, constraint was too anal
  * fix missing methods
  * allow specification of fields for menu query, etc...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * exposes issues converting procs from ls -> js
  * bugfixes
  * check in work in progress, overhauled uri, generate them automatically from slugs recursively..
  * more cleanup
  * merge conflict fix and a lil more
  * made various functions to recursively/automatically generate absolute uris for us (meant to be used after loading fixtures and at insert time)
  * active id for forum urls
  * load fancybox assets
  * fixed main menu active among other ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * working again (no 'mo site-id)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added fancybox
  * wip work to allow sub-posts to be added
  * use body text for slug in case of sub-posts
  * allow parent_id to replace title in validations, insert parent_id if they pass it thru
  * lol fixed the bug it was SOO easy and insidious, problem was with get-doc
  * remove debugging
  * generate a unique slug every time a post is made (for forum slugs, the onus is on the administrator)
  * remove cruft
  * remove un-needed second sql lookup
  * fix debug route for doc retrieval
  * works better than b4 but still borked
  * expand loop_prevention constraint to include equality since parent_id should != id ever
  * build_all_docs was incorrectly targeting all forums from all sites and assigning them the wrong site ids, it now is targets the respective site_id
  * fixed forum_doc_by_type_and_slug
  * made it work again, but only really works for site-id 1 for now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * now using async.map instead of for-loop
  * refactored to add site_id key through entire app
  * added forums and posts fixtures for our new sites
  * added davesan to users/aliases and gave him beer.pb.com
  * add helpers as h to repl
  * augment add-dates to included updated and more extensible as we add new date fields, and handle null case
  * testing lighter theme
  * flip backgrounds back
  * fix & simplify setting main menu active
  * hopefully, i fixed the problem in views/posts.jade
  * learning from Paul Graham's mistake ;) - http://www.reddit.com/r/programming/comments/18rluq/paul_graham_creates_a_loop_in_the_database_hacker/c8hf12a
  * wrapped all posts in div.forum; changed (if forum) to (if false) for now; not sure why mutant vs. non-mutant is so different
  * fdm=indent for app/mutants.ls as well
  * very broken, but lets you see a thread on fresh loads // no mutation yet
  * added posts to forum doc when thread is requested
  * fdm=indent works really well for livescript.  just use zO and zC to open and close recursively
  * exported u.sub-posts-tree as a stored proc
  * removed test stored proc
  * misc. layout & style
  * give thread links mutant powers
  * give subforum links mutant goodness, fix bug where title would not be set correctly from locals
  * make subforums use mutant transformations too (why is it that the toplevel menu items don't need the mutant class for surfing)
  * added default delay to scraper
  * bin/scrape-mma --forum N // scrape forums other than forum-id = 1
  * installed commander
  * some markup and style changes for forum list in left nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make full cell clickable on submenu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * restyled default theme and added /admin mutant stub
  * closes #18 z-index
  * post to active forum id instead of hardcoded one (Thanks mutant.marshal and keith)
  * bugfix
  * taming of the content
  * forums now can swap between recent and active from an url, but not anywhere from ui yet
  * create a new type of forum doc for the two sort types we have so far, recent / active, enable more limiting in sql all over
  * small refactor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unbork my route: http://mma.pb.com/debug/docs/homepage_recent/1
  * fix html
  * more map series
  * work in progress on thread handling code
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleaned up scraper a tiny bit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * higher-order fun to limit homepage overview
  * added thread list to nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of favicon.ico route, because 404 is working again
  * we have a working 404 page again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * decided not to use accordion, creating custom slide on hover/click for sub-forums & top-posts in nav
  * it's actually inserting posts; hardcoded to just forum 1 for now
  * post.body should be text (because post bodies can get big)
  * ajax/register -> auth/register
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a work in progress for scraping mma.tv
  * cssmin only in production
  * + cssmin for our /dynamic css route
  * upgrade jquery ui + custom bundle
  * adds custom css 'classes' to forums expressed in jade layouts
  * forgive me matt, temporary hack to get forums sorted the same as where I scraped them from
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * extra style for new data
  * reduced debounce to 100ms
  * adds forum id to html class and removes duplicate doc
  * sort forums by activeness also on homepagedoc (for homepage_active doc)
  * now building homepage_recent and homepage_active doc for sites
  * oops forgot this part
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * factor out everything to take a 'top-posts' fun
  * data from the wild
  * shorten merge function to 2 LOC from 3
  * used the power of immutability to cure my recursive headache, doc generation is buggy, should now be fixed
  * small refactor plus create our own immutable merge function for use in plv8
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add loc to posts
  * adds maxmind geoip and 3-stage targeting middleware; active on homepage
  * npm install hashish@0.0.4
  * added handy dandy debug route for seeing docs with jsonview in ff (or other pretty json viewing browser plugin), for example: http://mma.pb.com/debug/docs/forum_doc/1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * layout finesse
  * added id to auths table
  * fix bug in postgres recipe
  * fixed nodejs chef recipe, much less code, closes #1
  * chef recipe cleanup
  * handle unknown domains gracefully instead of KABOOM
  * more frontend finesse
  * theory code
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * your passwords
  * frontend fixes, menu animations, etc...
  * bug fixes galore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * massive commit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * created second denormalize blob for homepage
  * very rough local auth :: /auth/login and /auth/logout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix rate limiting
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create Passport for each domain; available in auth.passports-for-site
  * forgot to update client templates and entry
  * linkify header text for forums on homepage
  * yay add post ui is not broken anymore, also bodyparser moved to beginning of mw to stop hanging the connections
  * add-post fixed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed subforums in menus
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * workaround for lame globalness for now
  * use menu object instead of forums object for top menu
  * fix menu in data
  * latest changes
  * fix bug oop
  * use nicer name for procedures
  * watch the procedures too
  * build_all_docs procedure, to be ran after fixtures / data loaded in normalized sql tables
  * page loads but the mutants are funkyzz
  * latest wip data looking better
  * merge / latest wip oops
  * it works
  * adds forum path parts, site to varnish cache key & stubs for forum
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum doc + homepage doc now works
  * upgraded livescript
  * subforums + individual forum lookup added
  * merge conflict
  * formatting plus fix bug from doc rename
  * missed a spot: s/get-doc/doc/
  * s/user/usr/
  * verbiage refactor + syntax fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * main menus linked up better and start of subforum menus
  * drop if exist
  * fleshed out sites
  * fleshing out passport setup
  * faster restart
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added passport-twitter
  * added passport-facebook
  * added passport-google
  * vary post users
  * set active menu item on load
  * hook mw.multi-domain into db.find-site-by-domain
  * fixed typo s/Gproc/proc/
  * whitespace
  * pg.procs.find-site-by-domain()
  * mma forum theme, fixtures, etc...
  * + visionmedia's node-migrate
  * building out forum view
  * a couple bug fixes
  * added email to users schema
  * header toggler works again
  * split layout from entry (layout is now reusable) and then some
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * moved post resources there and refactored a bit
  * remove un-needed / placeholder stub validations file
  * more voltdb cleanup and misc cleanup, make procedure names even prettier in node-land
  * nuke data.ls allow multiple json parameters to be defined (positional)
  * default arg for callback
  * automatic json serialization, assume all postgres procs take a json blob for arguments and one json blob for return
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make put-doc more consistent with its rvals
  * added foreign key constraints to protect or dataz + fixtures that've been fixed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added a find_user stored proc
  * stop using data .. looking to delete data.ls
  * fix add post
  * remove legacy stuff
  * stylistic refactoring, call procs 'db'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix everything i broke
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + passport-local
  * fix add_post now that i unwrap the json
  * make put consistently return val
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * now that json is assumed, automatically unwrap json
  * various refactoring, remove unused codes, and target only return type json for node land
  * refining ur procedures
  * changed row.updated trigger to be called BEFORE update
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * find_or_create + add-post work
  * added unique on alias.site_id and alias.name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * improve ui with less data
  * more voltdb cleanup
  * assume ubuntu in nodejs and avoid problematic build-essential
  * drop database should not fail rest of script, sometimes db don't exist
  * add post form works and updates homepage (after refresh) woot
  * fixed upsert and the put-doc bug, arguments was dissapearing lol
  * fixed the upsert
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * gruntwork to compile plv8_modules/*.ls to *.js
  * removed subtransaction; upsert seems to work for both insert and update
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * get-doc shouldn't JSON.parse nulls
  * updated a table's sequence if it has one
  * default task boots pb again
  * volt cleanup
  * Merge branch 'postgres' of github.com:khoerling/powerbulletin into postgres
  * use builtin pooling, init just initializes procs now
  * misc.
  * matt's oneliners for bootstrapping pg rolled into a script
  * use local user on os x; otherwise, postgres
  * Merge branch 'master' of github.com:khoerling/powerbulletin into postgres
  * homepage load works with homepage doc from pgsql generated from add_post procedure !
  * smaller header when expanded
  * Merge branch 'master' of github.com:khoerling/powerbulletin into postgres
  * added onUnload to mutants and using css to manage mutant ui state
  * wrote put_doc2 and get_doc2 in data which use postgres instead
  * wip ported most of homepage building, just needs a lil more tweaking
  * Merge branch 'master' of github.com:khoerling/powerbulletin into postgres
  * add inline shared pure validations + serverside validations for procedures
  * bug fixes, ready for onUnload or some method of cleanup from mutant states
  * mutants switch more fluidly, latest layout, big refactor & cleanup, added left_content
  * more proof of concept stuff, like call procedures in our lib code
  * refactoring so sql doesn't make eyes bleed
  * proof of concept get_user with arguments
  * updated rest of fixtures for postgres schema
  * fix aliases fixtures, and users fixtures
  * wip converting fixtures etc to postgres, don't wanna break stuff in master
  * automatically populate postgres.procs from functions residing in postgres database 'pb' and in the generation, provide a function which automatically handles varargs
  * some stylistic changes to procedure, add postgres init to repl, without bugging ppl who don't have postgres running yet
  * tweak chef recipe to use our branch of plv8js instead
  * check in plls procedures modules folder which will be symlinked in production for reusable procedure code
  * add plv8 to chef recipe
  * updated schema to be postgresql friendly
  * inherit commandline args for bin/psql
  * hello postgres, goodbye voltdb (chef recipe for now, don't wanna break anything)
  * Revert "cleanup" welcome back, postgres
  * + build_form
  * non-working schema tweaks
  * adds forumdoc & slug to voltdb
  * latest changes
  * finally we can generate something that the view can consume
  * indentation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay homepage doc getting alot closer wip
  * + history.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * application/json
  * manually clone locals
  * work in progress for homepage building
  * added a secret in cvars
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip of toplevel forums and posts to build homepage doc
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest style & jade for clean /forums
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added express.cookieSession() middleware
  * added helpers.add_dates to turn created fields into Date objects
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in WIP for building homepage doc from actual sql tables
  * installed passport
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * npm install contextify via chef
  * point contextify with symlink to global install (chef recipe will take care of it)
  * start sequence for posts at 100 so we don't stomp on fixtures
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more fixtures, add forum_id to posts
  * removed contextify from node_modules; going global for compiled stuff
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * addd some utility functions, wip for build-all procedure, start of fixtures
  * /forum-(id) loading again
  * fix jsdom??
  * move stubbing into stored procedures
  * fix determinism in top posts fetching
  * small correction
  * check in comments for clojure n00bs
  * reduce data size
  * t pushMerge branch 'master' of github.com:khoerling/powerbulletin
  * bugfix to initStubs
  * /forum mutates and that's about it
  * forum wip 2
  * config tweaks to hopefully help responsiveness on nodejs client side
  * ui uses new clojure add-post2
  * yay add-post can serialize nice looking json that we can consume in nodejs
  * clojure procedure overhaul, we got nice abstractions now\ add-post2 now gens its own seq
  * decoupled homepage doc from a particulare procedure with build-homepage
  * fix broken defproc macro, we couldn't change namespaces so full qualification is needed
  * stop using broken procedure for health check lol
  * snapshot every 10s (to make dev easier for now) and the create command prints to stdout instead of to voltdb.log
  * separate launch and create tasks for voltdb, this way we don't stomp data accidentally
  * npm install clientjade locally, and update gruntfile accordingly
  * left/right forum mutant wip
  * sped up waypoints, added some css & data
  * sticky waypoints working better with awesome scroll-to
  * small tweaks that go far
  * + waypoints.min
  * ui fixes, added more sort/filter kinds
  * sticky forum headers
  * adds neat sorting ui and the triangles attack!
  * added smooth & smarter scroll-to functions
  * + blob.png
  * ability to add a custom css class to theme each forum
  * grunt, mutant & layout updates to work better with clientjade
  * an inverted theme and ui bits to make posting more obvious
  * split up jade templates, re-enabled mutant and loading homepage now
  * misc. style++
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * back to res.render
  * figured out how to make useful functions available to our clojure-based procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest compiled jade & grunt task
  * a little more refactoring ...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ok added updated/created to docs, more tweaks to first awesome clojure procedure (add-post)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add contextify to make jsdom happy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * clientjade + grunt task
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip on add-post
  * able to generate functions for whatever it's worth in tmpl.ls
  * jade template compiler
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made defproc more DSL-like
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remarked out templates
  * mutant working, though not rendering jade
  * cleanup
  * add-post2 works
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in wip add_post2
  * surfable routes part of mutant
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix health check
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest tweaks to make voltdb more resilient when connection is lost (in node land)
  * + jsdom & lowdash, process cache helper and mutant basics
  * check in WIP of voltdb timeouts + health checks
  * merge conflict fixerizer
  * enable snapshots, and loading of snapshots on startup of voltdb
  * grunt boots volt & zsh fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * append to voltdb.log instead
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more responsive add comment and a couple ff fixes
  * when you launch voltdb, try to load last snapshot
  * launch pb after voltdb is up and running
  * fixup hostname
  * snapshot every 30s
  * turn on auto snapshots
  * extracted defproc into its own file so other clojure voltdb procs can use it
  * recompile voltdb procs and start up voltdb through grunt
  * installed shell.js for convenience
  * added inline commenting among many other enhancements
  * better ui controls, faster background switch & working on user profile
  * fix bug in add-post that refactor broke
  * api cleanup, move stuff into data, move old api stuff out of voltdb
  * created a more dsl-like way to grab statements
  * proof of concept requiring of a tertiary module for the browserify bundle
  * browserify baby
  * and were back houston
  * whoops fixed bug where minified version wasnt used
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * switched to using component to compile our entrypoint, use lib/pb-entry/index.ls instead of app/layout.ls, also hooked up minification to new entrypoint
  * less initial chrome & extra sharpness to logo+forum separator
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * inverted post/subpost translucency
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * birth of 'defproc' macro for defining volt procedures
  * posts/sub posts
  * quicker initial build-in & waypoints update on resize
  * quicker initial load
  * slick background fx when scrolling through forums
  * top bar & search ui more integrated
  * menu mostly dynamic (need sub-forums to exist first) and layout+++
  * sharpness & the top drawer
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest style
  * added real ids to data doc & updated jade
  * fixes for select_user procedure and also forgot to checkout clojure branch for voltdb provisioning
  * add recipe to install custom voltdb for clojure instead of vanilla 3.0
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay partitioned procedures in voltdb + clojure
  * thinking about seo...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic waypoints among many other ui improvements
  * more randomization in test data
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make order determinate
  * readying for parallax categories & waypoints
  * fixes and speed/ui improvements
  * wip with clojure bizness
  * add a little more friendliness to the voltdb api
  * some refactoring, need 2gb ram for compiling voltdb, classpath more manageable now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * compile pb entry from component system, will integrate with grunt later and have grunt do the jade/stylus/ls stuff + uglify the final entry file
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored to work with latest voltdb schema
  * remove date header
  * check in WIP for components
  * adds volt+d for data to repl
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * bin/repl with preloaded libraries
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add component to npm global install
  * added lib/mutant and removted .git dir first
  * Revert "added mutant locally"
  * added mutant locally
  * change json serialization so it actually updates the front page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove comments, unified concept of posts
  * removed symlink
  * working on menus...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * back to single-width columns and misc.
  * fix: spacing
  * - bootstrap
  * jQuery is back (no more zepto)
  * i know its ugly but i want this placeholder somewhere =D
  * voltdb 3.0 tweaks, come back of clojure yay
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * npm install git://github.com/VoltDB/voltdb-client-nodejs.git
  * commit bugfix so it will compile for now
  * now using zepto!
  * resolve merge conflict
  * update to voltdb 3.0 (type vagrant provision to get latest voltdb first)
  * removed makeshift doc (for where voltdb isn't yet setup)
  * added 2 sizes of columns, improved masonry/pinterest style view and then some
  * massive ui bundle brosivs!
  * added docs and a caching function for hash index later..
  * change name to something more fun -- front page loads using doc from voltdb
  * homepage populated from docs now, use data.init-stubs()
  * give voltdb 256m for now
  * return all responses for AddPost
  * AddPost needs to be a MP procedure since the parameter is not hashed the same for both docs and posts
  * can now submit post to voltdb
  * fussing with ui/x, needs rich media in the content and to figure out how to stylishly and intuitively render threads+posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest ui concepts
  * everything is now single partition
  * everything is single partition now
  * sequences have arrived. we can now add multiple posts that generate their own unique ids in voltdb
  * screw classes, its all about ad-hoc data structures baby
  * oh yeah, my first procedure to populate both a json doc in the docs table and a post in the posts table, all with one procedure in voltdb land, all atomically
  * wip for json in voltdb
  * offline development (NODE_ENV=development) includes more js+css resources pulled from public/local
  * yay my AddPost procedure works
  * stylistic tweak
  * work in progress for a stored procedure which stores also a doc with json
  * add parent_id to comments
  * readability / consistency improvements
  * w00t my first worthless util function in clojure can be used on VoltTable[]
  * push up working voltdb procedure code, can still use clojure for meat but have to define VoltProcedure java files
  * chef recipe for postgres 9.2, app/postgres.ls shim for queries
  * install pg@0.11.1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in work-in-progress for voltdb procedures, still getting NullPointerException, but really close to working...
  * - vdb (should use data.ls instead :)
  * more ui mocking
  * + added js/local and auto-switcher for offline dev when NODE_ENV is 'production'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ui wip and then some
  * add shortcut to clojure repl, aot compile for voltdb will be different script
  * bugfix
  * clojure recipe
  * we now have reciprocal actions, put-misc-doc and get-misc-doc
  * create a convenience function for inserting a misc doc
  * remove default value
  * removed dead code
  * added some express validor stuff, will use this to create a registration process
  * install express-validator@0.3.1
  * placeholder route for registration
  * remove dead / not working code
  * factor our base_js_urls into new common.json config in config folder which is for configs which make sense in all environments
  * got schemaless with js urls
  * add script to kill everything in dev when grunt starts my stuff up too many times when code is broken, also, use cdn for headjs
  * buncha caching tweaks, treat varnish and cdns the same pretty much, remove cruft we didn't need, and blow the cache on js and css after each git deploy
  * removed manual js url since we should be using cdn urls for static resources, and since now our static server is tweaked to have a longer max-age now
  * simplify environment config loading, use builtin nodejs json loading
  * latest stuff, abstract locals into external datasource for homepage, keeping it high level for now
  * Revert "cleanup"
  * cleanup
  * Grunt, too
  * moved configs to config/ and fixed production error handler
  * initial skeleton for clientside of voltdb
  * npm install git://github.com/VoltDB/voltdb-client-nodejs.git
  * install voltdb tools also (which allows easy commandline save and restore of snapshots)
  * forward port 8080 for voltdb
  * add launch-voltdb script
  * prefer shorter 'type' to 'doctype'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * compile-voltdb script added, and initial placeholder schema based on my messing around
  * varnish tweaks, make dev mode not cache at all (1s)
  * no longer conditionally enable caching_strategies, just set the ttl super short in varnish
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove graffiti and see stager automatically put it out there
  * syntax wrong
  * graffiti added to test staging process w/ varnish
  * latest changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * test change to see if stager works
  * more tweaks so processes are killed properly
  * latest continuous indexer changes
  * die kitty, die, no more testing stuff
  * test
  * testing something else
  * tester
  * one last test
  * one last test
  * another test
  * test noise for stager
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * testing to see if staging is updated automagically
  * be more talky when you update staging
  * first whack at a pretty ghetto continuous stager
  * Update README.md
  * update readme about firewall tricks in mac os x
  * remove unecessary compiling of main.ls, remove config.json from version control and ignore it, that should be copied after cloning into place depending on env
  * enable max-age in the express.static middleware, so we get nice cacheability
  * update main.js
  * varnish file tweaks to hide some headers and allow webapp to have explicit control over varnish ttl again
  * setup varnish with basic config to start which has gzip enabled
  * use pbstage.com for staging
  * need build-essential for gem installation
  * forgot to skip the interactive part
  * added script to provision servers apart from varnish
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * avoid sadness
  * grunt using config.json & moved pid to /tmp
  * buncha etag tweaks
  * added details to readme
  * yay grunt works on vagrant and global npm install too
  * check in recipes for nodejs, stunnel, varnish, voltdb, vagrant up works with ubuntu 1204, livescript and grunt preinstalled globally post npm and nodejs
  * initial vagrant stuff, one can bootstrap an omnios box but the recipes dont do anything yet, apt-get u was my friend, now i have to do more work ; )
  * see if i got access to git repo
  * working on ui frame
  * "launch" grunt task fixed and server now restarts automatically!
  * refactored jade views into blocks
  * refactored common into helpers and added folds+comments
  * rendering test data and added common functions
  * working on posts...
  * using centered header layout & added scroll-to-top
  * amazingly responsive start on the skeleton layout (borrows from digg, reddit & express), added a dynamic route for ls -> js, separated stylus theme which'll get replaced by site-specific ones later, and many other goodies
  * now serving a fresh cup of static cache-domain content
  * cache domains, responsive 2-column layout (needs spring for right-nav), stylus+fluidity+layout theme, and so much more!
  * adds concept of handlers & express-resources, and some middleware goodness
  * initial route in-place: http://www.localhost:3000/hello & basic middleware
  * added ability to host multiple domains per express instance, fixes & working on "grunt launch"
  * + fluidity
  * the rest...
  * ./bin/PowerBulletin launches!
  * initial grunt'work & skeleton
  * Initial commit

n.n.n / 2014-01-13 
==================

  * fixed panel removal selector
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: using click again
  * force initial transition to have 0 delay
  * chat-panel transition
  * added set-profile to list of required fns
  * fix: crash for imported form data without a .form
  * top-right tool menu animates less
  * adds ability to add custom domains in /admin
  * added oneliner thread list for left-content
  * cleanup locked toggle
  * remove console.log from push-state wrapper
  * added profile link and then some to Chat Panel
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wrap around History.push-state to work around bug
  * cleanup dirty, dirty hack alert
  * fix: always summarize, even when surfing
  * disabled pins (for now)
  * latest menu summary and then some
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove console.log
  * optional animation for scroll-to-latest
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * when removing, be aware that some panels don't have icons
  * glosss buttons back!
  * added data-time attribute to chat messages
  * added template for chat list item
  * ability to select past chats
  * almost have chat list working
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: decorate crash & playing with new data
  * 404++
  * added chat-past message to load list of past chats
  * cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sort by most recent msg and add participants to db.conversations.past(cid, cb)
  * using new forum summary query for thread & post count
  * added ChatList component (currently empty)
  * fix crash when marking message; wrong user id
  * fix crash when forum-ids is empty; may need more work
  * message automatically marked read for sender of message
  * mark all read on open
  * increment notice when chat panel is minimized
  * (404 & 50x)++
  * adding stats. to homepage & forum homepage views
  * animations (needed fluidity) on 404 & 50x pages
  * Revert "upgraded fluidity"
  * upgraded fluidity
  * switch between prod/dev for 404 & 50x
  * new 404 & 50x pages
  * fix: google font is back
  * remove menu from surfing data
  * fix: main menu working again
  * when disconnected add a disconnected class to html tag
  * load old messages when scrolling back
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * trying to load previous messages
  * menu summary on top-level at given depth
  * frontend for unread messages
  * filter out conversations with no unread messages
  * chat-mark-all-read
  * added an unread class to unread messages
  * add data-mid to li
  * chat-mark-read, chat-mark-read-since
  * style for messages li
  * Chat & Admin UI
  * load initial messages via socket.io instead of xhr
  * initial chat notices
  * cleanup
  * latest jade
  * fix: all templates work w/ latest jade!
  * in anticipation of upgrading jade
  * fix: "input" has become a parse error in latest stylus?
  * upgraded stylus
  * fix: really initially scroll to bottom
  * properly close existing chats and be able to reopen them again
  * @scroll-to-latest
  * changed original should-scroll to near-bottom
  * scroll-to-latest and take image loading into consideration too
  * fix: ui properly collapses with removal
  * + mark read since
  * added first_unread_message_id to db.conversations.unread-summary-by-user
  * panels can be removed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * load initial messages
  * removed console.logs
  * fix: scrolled menu working
  * fix: improved clickable top-right corner
  * fix: clean up ParallaxButton style & don't move SiteRegister when clicking Create
  * fix: buttons always clickable and then some
  * icons & online in full-force
  * resolved.
  * socket.emit 'ready'
  * 'fixed' globals and fixed ChatPanel.add-conversation
  * properly eat returns & better handle key input
  * fix: really scroll to bottom
  * Chat++
  * fix: hoping to improve background sticking around issue
  * fix: use window.user if no local user
  * space out chat avatars
  * check for window's existence
  * amdefine for shared/format.ls
  * trying to setup reactive vars for chat on-personalize
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest chat ui
  * add list of participants to unread message summary
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * chat-unread is for finding out what chats have unread messages
  * cleanup Chat.*
  * fix: lazy-load autosize
  * remove stray console.warn
  * sneak in code to upconvert old messages without .html
  * use messages.html field instead of messages.body
  * moved formatting code out of server-helpers into own module
  * added messages.html for prerendered version of chat message
  * left/right alternation
  * removed unused experimental db code
  * oops, +Homepage.styl
  * *bomb*
  * seo++
  * Chat++
  * fixes: a few menu items are missing forms
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * run shared-helpers.add-dates on pb-model fns
  * recursing for MenuSummary
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: should be run last, might help w/ background lingering
  * added descriptions to menu items
  * hide post creation ui when thread or forum is locked
  * add locked class to body when thread or current forum is locked
  * upgraded cherio
  * cleanup forum description field
  * what was chat-server.send is now db.messages.send
  * focus after .show() finishes
  * add alias info of sender to message so recipients can show photo
  * remove app/chat.ls
  * remove debugging noise
  * focus textarea on open
  * messages are moving back and forth
  * fix: scroll to top on homepage mutant
  * fix: always remove spin class
  * fix: use destructured
  * Buy++ & misc. frontend
  * MenuSummary tracking active menu id & rendering!
  * increase clickable region for drop-down
  * Posts per Page -> Replies per Page
  * better distribution of cache-domains
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui
  * initial setup on MenuSummary & Pins for Homepage
  * don't make locked marker look clickable for non-admins
  * style for locked threads for non-admin users
  * forums now have their own posts-per-page setting
  * fix: discard event more selectively
  * Shining the shiny and more polish
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: prune background-color div, too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * thread locking ui for admins
  * fix: notes offset, etc...
  * only allow menu item to move after save
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * consolidated admin/domains into admin/general
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * setup thread nav controls on-load
  * cleanup
  * allow non admins to edit posts
  * made db.posts.toggle-locked consistent w/ toggle-sticky
  * route for thread stickiness toggle
  * move click handler for thread sticky toggle
  * code for showing/hiding thread stickiness admin ui
  * added markup and style for sticky toggle
  * fix: discard textarea click
  * added menu to repl
  * tooltip++
  * click to hold open admin menus
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: race condition should be fixed (no more yield)
  * misc. frontend verbiage & focusing
  * auto-save only checkboxes with .save class & only stylize .stylish checkboxes
  * tooltips now keyed to their id
  * added some padding to the bottom of ul.threads
  * delete should delete
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only look up user_id once
  * delete pages and forums by just using their id
  * fix: handle error when deleting
  * fix: rids horizontal scrollbar
  * added a helper method for adding new chat panels
  * Merge branch 'master' into chat
  * added link to past chat list / doesn't do anything yet
  * added a sticky class to sticky threads in left thread list
  * always allow menu item to move (even if unsaved)
  * fix: only show admin switcher when multiple sites
  * autovivify chat-panels as needed when new messages come in
  * this method must've disappeared during a merge
  * grab chat id via socket.io
  * removed deprecated comment
  * let ChatPanel figure out where the message goes
  * clear-stale-redis-data(redis-client, cb)
  * active thread arrow++
  * active arrow++
  * every ./Component is now a ./PBComponent
  * Buy tooltip++
  * fix: runtime error, needed to specify parents
  * fix: subscription crash
  * Single Homepage PBComponent for Mutant
  * + PBComponent
  * Component cleans up DOM
  * merged
  * chat-message handler (server-side)
  * focus & select
  * removed debugging noise from local login flow
  * thought db.forums.summary was more appropriate here
  * constrain announce to site.id room
  * colors...
  * hack to allow saving of top post
  * editing of posts less crashy, but it still doesn't quite work for first post of thread (need title separate from body)
  * added user_name and user_photo to result set
  * inital wip for new homepage
  * run time updater on every surf, too
  * socket.emit 'ping' on every surf
  * added ping to tickle alias.last_activity
  * don't crash
  * another temp fix
  * fix: crash (this is temp)
  * Merge branch 'master' into chat
  * added limit param to db.{sites,forums}.summary
  * resolved conflicts; broke chat in master
  * fix: don't redirect on jquery logout
  * logout without refreshing page on Sales
  * fix: Sales after-login working again (oops)
  * fix: git-extras disappeared?
  * cleanup homepage
  * misc. ui
  * misc. Sales tweaks
  * adds a Placeholder menu type
  * cleanup
  * fix: Editor buttons clickable again
  * removes mutant dependency from Sales page
  * - globals
  * hoping to add globals.js to the production bundle
  * fix: remove locally-stored user in forum app & sales app
  * no more double-marshal of locals
  * fix: hostname click/focus
  * removed many conversation_* stored procs
  * Merge remote-tracking branch 'origin/prod'
  * fix: use pre-compiled stylus on production Sales
  * Merge branch 'master' into chat
  * fix: cache-url in production
  * fix: left nav correctly draws when scrolled
  * fixes: fb share icon clipping & post date wrapping
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * last round of tweaks from yesterday
  * solarized tmux for root
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.build-all-uris site-id before upconverting
  * fix: cookbook
  * Merge branch 'master' into prod
  * fix: init default menus on deploy
  * fix: load waypoints in production
  * Merge branch 'master' into prod
  * fix: optimized builds working again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + ack, too
  * Merge branch 'master' into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of configs specific to my systems
  * vim bundles
  * don't want git submodules of vim bundles
  * merged
  * added symlink for prod. plv8
  * added symlink for prod. plv8
  * deploy in a single step, added steps + cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' into chat
  * our latest recipes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default vim config
  * default vim config
  * removed unfinished feature from ui
  * fix: crash from bad user input
  * eMkel tweaks
  * Merge branch 'master' into chat
  * prevent crash in posts.jade when social is not available
  * Merge branch 'master' into chat
  * expose post.media_url and post.images in db.forum.summary
  * fix bug where top post would lose its media_url
  * insert images and assoc them to posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' into chat
  * add images.{created,updated} timestamps
  * table for thread subscriptions
  * table for following users
  * reload -> reloj
  * fix: use first domain in admin switcher
  * admin group for Look & Feel
  * fix: prune multiple *.pb/*.powerbulletin domains from membership list
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reload after choosing user name for 1st time on private site
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * mark that the sender of the message has seen the message
  * Merge branch 'master' into chat
  * ported reload(module) from wm code; seems to work in the repl now
  * more chat related db queries
  * Merge branch 'master' into chat
  * fix: exclude current site from admin switcher
  * admin site switcher
  * fix: completely reload social links every mutant load
  * organized General Admin w/ collapsable SEO Options
  * + admin-able social links for forum pages!
  * added a toggler for PanelCollection
  * more cross-browser & bigger tooltips
  * Sales & MiniSiteList polish
  * Merge branch 'master' into chat
  * cross-browser compatibility++
  * remove deprecated chat server handlers
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: defer user lookup to avoid null case
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't print times on server-side, let client figure it out
  * Merge branch 'master' into chat
  * fix: tie editor local storage to user.id
  * fix: tie left-nav ui settings to user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: anchor /admin redirect to beginning of url.pathname
  * announce to right path, removed to-id param from chat.send
  * misc. Sales ui
  * on-personalize for @page
  * connect.sess cookie expires in one year
  * misc. ui++
  * post & comment actions wip
  * marked up latest spritemap
  * dropped another design b0mb on Sales
  * active thread arrow responds to nav size
  * comments on db.conversations.{participants,between} fns
  * chat.send c-id, from-id, to-id, message, cb
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.conversations.participants c-id, cb
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * signatures in post views!
  * db.conversations.between site-id, users, cb
  * less confusing cursor style (default arrow) for disabled controls
  * db.$table.attrs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: z-index from covering FAQ, etc...
  * hardware accelerated parallax
  * new image includes radial blur to speed up scroll
  * pruned old images (cleanup)
  * remove stray console.log
  * fix private site issue
  * brainstorming with beppusan
  * fix: can't remove the middleware
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * SuperAdminUsers ready for bigger changes
  * require prelude-ls, remove comments and console.logs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resolve conflict and make disable/enable more accurate
  * close tooltip unless message
  * removed hack & destructure show-tooltip exclusively
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * removed SalesRoutair
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of throttle on scroll
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui, animation timing & dom simplification
  * newline in front makes it look better in firefox
  * accidentally checked in debug code
  * typo
  * standardize on select-one, select, update-one, update
  * menu.extract doesn't have to stringify page.config anymore
  * guard against null thread_count
  * forgot to handle err
  * temporary hack to prevent excessive handlers from being set up
  * first pass on forum chat bubbles
  * layout chrome++
  * added arrow to left-nav active thread (from comp)
  * latest spritemap
  * fix: colors for dark theme
  * save nestedsortable tree state in local storage
  * seo++
  * fix: no more #forum_background_color dups
  * handle++
  * fix: reap background_color
  * fix: remember left-nav width after collapsing & refreshing page
  * background color for forums, forum homepages & profiles
  * sets up primary & secondary overlay & tint colors
  * ++(Add User & Invite)
  * Revert "pages may override any path, even /"
  * fix: more cookie removal (oops, missed a spot)
  * fix: misc. stylus
  * fix: load order of Sales
  * fix: delete user local storage on logout
  * smoother scroll
  * darker images w/ transparency applied
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest Sales page!
  * Merge branch 'master' into chat
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pages may override any path, even /
  * fix: rounded photos clip properly
  * fix: Editor crash
  * refactor: replaced $.Cookie with local storage
  * wip
  * explicitly update local storage user from socket.io
  * fixes & embellishments to Editor & mutant
  * Editor has preview toggle using local storage
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add chat panels when chat button is clicked]
  * window.components.panels = new PanelCollection
  * Editor no longer saves randomly
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: autosize on profile mutant, too
  * faster, non-blocking on-personalize w/ local storage
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixing icons, playing w/ positioning
  * simplified Editor w/ lodash.throttle
  * upgraded lodash -> 2.3.0
  * use local storage with Editor component
  * wip panels
  * counting threads (humanly) on profile pages and then some
  * editor pop-ups now in PB flavor
  * *bomb* on profile
  * local storage api
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes for Editor & Sales
  * console flair
  * fixed syntax error
  * tie signature into user
  * Editor saves one last time before detach!
  * signature saving!
  * fix: only save whitelisted alias.config keys
  * fix: escape to close all Auth inputs, too
  * escape to close Editor
  * automatic setup of serialized db functions
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: sales transitions are back, oops
  * misc. ui
  * latest Editor
  * fix: crash when searching
  * preparation for automagically setting up basic select/insert/update/delete for tables with ids
  * /auth/once-admin
  * misc. fixes sitting w/ beppusan
  * fixes: misc. stylus ui
  * optimization: only swap forum backgrounds when different
  * smoother forum transitions and then some
  * MainMenu component++
  * 3rd pass on Sales page
  * + PageDown npm, whoops
  * + initial Editor component
  * + PageDown, loading now w/ requirejs
  * black is the new pink or more auth+controls ui
  * *bomb* 2nd pass on Sales homepage comp.
  * fix: is the css animation affecting clicks?  let's find out...
  * testing "oval" fancybox theme on privatesite
  * beginnings of new sales page et. al
  * fancybox black edition
  * be careful when joining aliases
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactor: consolidated SalesApp into Sales
  * summary wasn't able to see threads with only one post in them
  * reformatted sql for db.forums.summary
  * join aliases against both posts and forums
  * added counts to db.aliases.participants-for-thread(thread-id, cb)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: use lowercase (more globally appropriate)
  * tidy: store forum backgrounds in /bg/
  * commented out media_url from homepage
  * migration for images table
  * db.forums.summary(id, cb)
  * db.sites.save-style(site, cb) extracted from pb-resources
  * stubs for ChatPanel component
  * added hide and show methods
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix bug where wrong alias.name could show up in profile
  * misc. Auth ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.aliases.participants-for-thread(id, cb)
  * PhotoCropper enhancements
  * - body on homepage view
  * black #theme
  * panel wip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * server-helpers.dev-log-format (wanted hostname in dev logs)
  * fix: hide last activity if none
  * update user title over socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes: homepage
  * fix: limit set-profile to tools menu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * touch aliases.last_activity on registration
  * added 12-time to strftime
  * fix: oops, spacing
  * using minified strftime
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to add symlink
  * left-nav looking closer to comp.
  * adds last activity & titles to forum posts
  * strftime and friendly dates on the client side
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * moved add-dates back to shared-helpers
  * opaque login dialog on private-site
  * initial pass on user titles
  * secure aliases update to site
  * notes for beppusan
  * fix: friendly time reversal & human fn bolding
  * last_activity and friendly dates
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added _friendly dates (Day Month day, YEAR)
  * installed strftime
  * moved add-date to server-helpers
  * profile page ui
  * fix: keep "Posted" outside of date fns, into views
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * start of aliases resource + rights
  * just in case user is null
  * touch aliases.last_activity on login, logout, connect, disconnect
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + last_activity
  * fixing weird bugs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check for length differently
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' into no-orm
  * removed thin-orm node module
  * replaced code that used thin-orm
  * select1 and updatex for aliases, pages and subscriptions
  * fix: show .summary on new forum reply
  * fix: must be wider for beppu's wide-ass resolution
  * fix: min-height isn't necessary anymore
  * fixes: // -> / in photo resource + no-longer escaping html
  * incorporating emkel comp. with our own flavor
  * reply textarea grows among many ui enhancements
  * added deserialized-fn and updated select and update fn generators
  * resolved conflict
  * fix: "Posted" in time updater, too
  * add Posted to posts & escaped <html> for security: XSS, etc...
  * more homepage & forum ui
  * main menu++
  * Sales* refactor + cleanup + fixes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. fixes for older browsers
  * beautiful crash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip saving user/alias info
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass of combining fulltext search with users.all query
  * wip for db find fn
  * Merge branch 'master' into no-orm
  * db.aliases.update1(obj, cb) and db.users.update1(obj, cb)
  * mark all spots where thin-orm needs to be removed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added db.posts.toggle-sticky(id, cb) and db.posts.toggle-locked(id, cb)
  * added db.posts.upsert
  * content-only admin feature working!
  * fix: don't submit on enter key
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix unit tests broken from commit e2ec4c37cf4fb98ae9293700447b7b7f4b21d397 (elapsed-to-human-readable)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix #warning
  * fix: don't crash if tooltip is non-existent
  * user admin paging + styling
  * constrain list of users by site.id
  * cats.pb.com => community; sorry mr.clifton
  * fix: AdminMenu tooltips
  * profile++
  * SEO, layout & human-time improvements
  * replaced head.js entirely with requirejs + cleanup
  * fix: hide/show "Change Password" if editable -- oops
  * cleaned out plax and misc. ui
  * admin checkboxes auto save and then some ...
  * low-hanging fixes
  * added memberships to MiniSiteList
  * secure cookies!
  * if user lookup fails, don't crash
  * forgot we went back to using name (instead of email) in session cookie
  * fix: only delay MySites for @login
  * fix: build register link in immediately
  * Merge branch 'auth'
  * bug fixes for joining a site and choosing a username
  * disabled parallax viewport
  * allow existing pb.com users to choose username when joining a *.pb.com site
  * Merge branch 'master' of github.com:khoerling/powerbulletin into auth
  * server-side for existing user joining a site
  * sensible auth field blanking
  * adds "Change Password" to profile page among more ui
  * help @login find the info it wants
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * rights management WIP
  * bold numbers and their metric for human readable
  * profile page has latest activity date among other ui
  * hide footer unless scrolled
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * delay creation of default aliases until auth-handlers.choose-username
  * using css to switch checkbox label text, eg: on/off
  * first pass at rights library which will be used for rights logic everywhere else (including handlers)
  * sql syntax error fix
  * forgot to JSON.parse some user and alias attrs
  * user.sys_rights for matt
  * resolved conflict
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * private site intro round 2
  * fix: crash if background doesn't exist
  * Merge remote-tracking branch 'origin/master' into auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hide title in reply drawer & focus ckeditor on reply
  * tighter post layout, profile page is more obvious & misc. spacing, colors, etc...
  * moved all site stylus into public/sites/SITE-ID
  * fix: added domain-id to site's auth.styl
  * all tooltips stay visible longer
  * add default aliases on 3rd party auth registrations
  * hide passwords by default
  * fix: always leave a modal dialog open at all steps in auth for private site
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * be more generous with module timeouts in requirejs
  * fix crashes that prevented default aliases from being added
  * bumped up pagination
  * bumped up pagination
  * add default aliases when new users are created
  * use conditional inserts for adding default aliases
  * fix: re-enable submit button
  * Merge remote-tracking branch 'origin/master' into auth
  * fix: migrate in production
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: migrate in production
  * Revert "upgraded uglify -> uglify2 through grunt-contrib"
  * Revert "upgraded uglify -> uglify2 through grunt-contrib"
  * fix typo; i thought i did?
  * Merge remote-tracking branch 'origin/master' into auth
  * add system rights, update user editor accordingly, backend code still needs some work before the loop is complete
  * don't count javascript twice
  * add bin/cloc for code metrics
  * merged
  * merged.
  * Uploader component can delete
  * simplify render-component so it only uses the initial case and doesn't require the programmer to think about reusing component classes
  * checkin WIP for UserEditor, mainly server-side and validations are all that are left
  * fix: rebind expand & collapse behavior after addition
  * Merge branch 'master' of github.com:khoerling/powerbulletin into auth
  * add default aliases to user on local registration
  * db.aliases.add-to-user(user-id, site-ids, attrs, cb)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ui love to user admin & table
  * fix: oops, AdminMenu working again
  * use cache server to load socket.io library instead of socket.io directly (prone to crashing), simplify varnish config
  * Merge branch 'master' of github.com:khoerling/powerbulletin into auth
  * s/Help/Forgot/
  * when user not found, fail gracefully and correctly
  * init pb-models; fix io-server bitrot
  * made failure messages vague (on purpose)
  * AdminMenu fixes & folding
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * re-usable Uploader component
  * Merge branch 'master' into auth
  * use db.users.by-email-and-site where appropriate
  * add user.site_id for current site_id
  * refactor css so keith doesn't yell at me
  * edit user ui first pass
  * forgot that user.auths was an object (not a list)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix auth for SalesRouter
  * whoops
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. vanity
  * db.users.by-email-and-site email, site-id, cb
  * race condition fixes for private site
  * upgraded uglify -> uglify2 through grunt-contrib
  * url generation abstracted away from SuperAdminUsers component
  * user admin in forum app first pass, pagination works on initial load only, need to add url to forum-urls lib for client mutations to work
  * comment on users.email 'local auth email'
  * misc. ui
  * private site++
  * start AdminMenu collapsed
  * expanding & hiding AdminMenus
  * fix: crashish when !user
  * fix: crash if socket.io doesn't load
  * future TODO notes
  * misc. up w/ beppu
  * frontend for login with email
  * login with email instead of alias.name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: correctly update version in a single transaction with up
  * after 3rd party auth finishes, set reactive var r-user if it exists
  * run bin/migrate at end of create-pg
  * save site.config.private correctly
  * fix: crash
  * fix: sql fat-fingering
  * misc. admin & more translucent theming
  * parallax & auth dialog diming on private site
  * slick grow fx for private site background transition
  * fix: guarantee auth dialog shows on private site
  * preparing chrome for translucent tint-color/backgrounds
  * fix: don't show footer reply except html.forum mutants
  * verbiage changes & friendly placeholder for User Admin
  * fix: forum backgrounds have tint directly applied
  * misc. frontend to Buy & Sales
  * migrate reports more usefully + 2nd migration
  * rotate & fade-through all forum backgrounds on private site auth
  * verbiage
  * background refactor & bug-fix
  * Sales++ & MiniSite++ & Cross-browser
  * Better Buy experience
  * post/edit interface++
  * *b0mb* on Site List
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * *bomb* on sales
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * make stdout from backup script more helpful and include a timestamp
  * update readme, had to tweak crontab again
  * add crontab notes to README
  * bin/remote-backup script
  * fix: cache-bust on write
  * SuperUserAdmin placeholder
  * misc. ui
  * cleanup
  * migrations (first pass)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use normal 404 handler instead of custom
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tamed mainmenu, readying drawer ...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * numerous code cleanup, bugfixes, and tweaks for SalesRouter, and SuperAdmin
  * powerbulletin key & secrets!
  * fix: race condition between sales-entry & layout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check for error condition more explicitly
  * misc. ui improvements & cleanup
  * automagically show site list if logged in
  * consistently report errors, fixed register/auth tooltip, etc...
  * fixed bug in register-local-user where guard was too strict
  * server-side guard against invalid domains
  * a little more kosher ;)
  * remove stray space
  * sales & site list++
  * forum ui++
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: crash if site hasn't got config
  * fix: cleanup backgrounds
  * wip on cli product subscription script
  * fixed typo
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. colors & cleanup
  * double-buffer backgrounds between forum changes
  * added admin user for site_id 1 (pb.com)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * show a different msg when user has no sites
  * lazy-load + animate background <img> on private, homepage & forums
  * link to admin
  * added callback to @login-with-token
  * implemented #once-admin for going logging in and going to /admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pass site info to MiniSiteList component
  * styl for mini site list
  * fleshed out template for mini site list
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * background on private site mutant!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to pull in sort-by fn
  * route for list of current user's sites
  * added user_count and return list instead of object
  * forum backgrounds work at the thread level, too
  * fix: clickable region
  * fix: always set active
  * fix: Uncaught TypeError: Object [object global] has no method 'rUser'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass at forum backgrounds on frontend
  * really fix mainmenu offscreen slide
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hook up MiniSiteList to SalesApp
  * db.sites.owned-by-user(user-id, cb)
  * component for mini site list
  * more evil yoshida & eMkel comp. ui
  * fix: main menu won't snap back n' forth with big submenu content
  * fix: don't crash on blank menu
  * made reactive far window.r-user work again
  * added link to My Sites
  * misc. ey ui
  * per evilyoshida: removed jquery-nicescroll
  * addressing some evil yoshida feedback
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: profile login/out link bug
  * full urls for SuperAdminUsers
  * code cleanup, add gen (opposite of parse), and fold mappings into urls file
  * added Reply button in footer from comp.
  * fix: footer resets left on homepage mutant and then some
  * oops, forget 1px transparent image
  * cleanup
  * everything part of forum backgrounds save to server
  * adminmenu forum backgrounds have thumbnails
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: main menu scrolled offset & potential crash
  * fix: reload MainMenu component after blasting away
  * know when sighup triggered restart
  * in domain section of admin, default to current domain
  * added links to sites where you can request api keys
  * beppusan is now admin
  * fix: never detach main menu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * back/forward working between super & sales
  * put switch-and-focus on window so 3rd party registration works again
  * SalesRouter immediately blasts content out of DOM
  * Revert "fix: mostly covers fancybox"
  * fix: mostly covers fancybox
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix querystring issues with surfing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum background wip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * delete existing passport for domain so new one can be created
  * factored move into server helpers
  * translucent footer
  * pass active-page local from server
  * remove console logging
  * latest SalesRouter tweaks, routing is now integrated into SuperAdmin states (and urls)
  * routes are now mapped to SuperAdmin states, drilling deeper ; )
  * Merge branch 'salesrouter'
  * fixed bug duh
  * populate route local automagically in top-level components
  * implemented traditional thread sorting (by date of last post in thread)
  * admin & main menus++
  * forum background wip
  * lightly move footer out of the way & back
  * SalesRouter now knows how to touch a reactive variable 'route' instead of changing layouts when moving between routes which map to the same top-level component
  * remove items which don't belong in version control
  * s/user/req.user/
  * disallow non-admin posts from locked forums
  * removed debug msgs
  * stickiness trumps all when sorting top level posts
  * misc. profile, paginator & layout improvements
  * comp'd out profile/tools menu
  * show/hide scroll-to-top & matches comp.
  * pager styled like comp.
  * scrolling alignment among other ui fixes
  * sales router now reaps old top level components after 3s
  * Merge branch 'master' into salesrouter
  * cleanup
  * got rid of unnecessary default param values
  * note for possible future expansion of moderation log
  * code alignment
  * make sure there are no undefined states in state machine
  * changed misleading comments
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tooltip to prompt admin to select a menu item type
  * fixes: main menu
  * using MainMenu component--working quite nicely!
  * numerous ui tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: main menu stays open without losing the hover due to padding shrink
  * added placeholders and guards for page and forum slugs
  * set default profile pic on registration from sales app
  * marketing notes
  * add validation so that uri's must always be present
  * misc. frontend improvements: main menu/layout/logo/textual
  * fix: crash if no uri
  * fixes: parallax
  * only parallax images in view when scrolling
  * fixed bug in struct-upsert
  * fix: parse-int each item before using maximum
  * latest menu ui, looking sharp!
  * intelligently reposition main menu when offscreen
  * Sales+++
  * switch ui control++ (ios7-themed)
  * added testing harness for new main menu
  * Sales Page:  generic arrow (animated) + cleanup
  * improved focusing & scrolling behaviors
  * main menu jade mixin has recursive depth tracking
  * + move down animation
  * tune the Paginator to be more consistent with the visibility of First/Last
  * add arrows to Paginator component per emkels comp
  * Ready to begin fleshing out main menu
  * fixes: Sales
  * common controls++
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * ios7-style switches
  * fixes: ui error class & logo
  * first iteration of Table component, combination of normal table, and paginator control
  * remove file from version control which doesn't belong
  * no need to put requirejs-config in server-side locals, it is loaded in a self-contained module now
  * exorcise datatables
  * fix forum filtering in search in light of menu change, fix reinit-elastic script to point to new log file
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * initial MainMenu component
  * only allow items with a type to be sorted
  * sales page waypoints
  * fix: menu admin gap
  * cleaner common controls
  * menu admin++
  * fix super-admin navigation links
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * sales focus & finesse
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added nav to sales page
  * offline in development
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * menu-item.forum-slug needs to be old-item.uri
  * give newly created sites a site.config.menu
  * menu.upconvert wasn't handling forum.uri correctly
  * forum urls weren't working
  * misc ui
  * Revert "upgraded jquery waypoints"
  * AdminMenu *b0mb*
  * stdui++
  * upgraded jquery waypoints
  * fix: title crash on main menu
  * fixes: reply-related focus issues
  * fix: - ui background colors
  * top/right profile & standard controls +++
  * fix: reply no-longer steals focus
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * always resize left-nav
  * misc. admin ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * menu has to be generated after forum uris are generated
  * notes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * users.photo moved to aliases.photo
  * fix: page layout::static runs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to add app/views/menu.jade (wrapper around mixin)
  * fix: on-unload crash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: active menu highlighting, and then some!
  * handler for menu-update socket.io msg
  * make site var available to @homepage
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * always show default avatar
  * emit a menu-update message to all clients when menu is updated
  * Merge remote-tracking branch 'origin/master' into menu
  * just one to grab the first parent when deleting from dom
  * using site.config.menu everywhere!
  * fix: f (forum)-> menu + draws correctly
  * Merge remote-tracking branch 'origin/master' into menu
  * fixed saving of external links
  * Merge remote-tracking branch 'origin/master' into menu
  * finally defeated the focus bug?
  * replacing forum-based main menu with site.config.menu
  * move initial attach code into attach phase of SalesRouter
  * add notes on how i re-init postgresql with utf8 forced
  * code cleanup, it had gotten kinda gnarly, real deal, ask beppusan :D
  * misc. ui w/ emkel
  * misc. ui w/ emkel
  * Merge branch 'master' of github.com:khoerling/powerbulletin into salesrouter
  * make sure fancybox is visible when appropriate
  * relocate auth tag
  * properly embed Sales in SalesLayout
  * w00t can now embed layouts on the fly with SalesRouter
  * fixed the sales optimized build
  * initial page loads now properly attach to existing dom nodes without a re-render
  * remove dead code
  * log message to console when skipping render and only attaching
  * a little code cleanup and some bugfixes
  * history state integration with SalesRouter
  * code cleanup, bugfixing, and don't explode when trying to navigate to an invalid url, return early and politely warn the console, bound to happen alot in production, don't wanna hose the javascript app
  * menu update should be better; still have some focus issues
  * some code cleanup, hook up SalesRouter to History api
  * bugfixes and css for page transitions in SalesRouter
  * misc. ui
  * social auths on login & register dialogs
  * fix: auth stylesheet back in business
  * bundle of ui fixes
  * can mutate from button clicks!
  * body.disabled puts a gloss over screen
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unsuccessful attempt at fixing menu update issue
  * w00t, optimized build works now
  * tweak waypoints
  * fix typo
  * cdnify waypoints, tweak optimized js builder so it builds correct dependencies
  * more comp. on the forum
  * components can now be uglified
  * yay, i think maybe i solve uglify problem, testing now
  * various tweaks, and bugfixes
  * checkin latest wip, can now navigate between two sales pages, need to now hook up css for correct hiding behavior
  * holy crap, it actually sorta works, more polish to come, checkin wip
  * checkin wip, major refactor, routing is coming together nicely, will get back to superadmin after i reach a stopping point here
  * *bomb*
  * SalesLoader becomes SalesRouter
  * create sales-urls in same spirit as forum-urls but super simple for now until we need something more complex
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * another step toward fixing focus issues
  * check in work in progress for site admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * design bomb on wrapper
  * focus on something sane after deletion
  * append $sub-ol to right element containment
  * fix: display logged-in profile
  * forgot to call reverse!
  * responsive sales page (for mobile)
  * on menu save, return database id on success
  * attempt at recursively deleting menu items
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added menu.flatten(menu) to flatten items prior to deletion
  * fix: oops, pruned .js
  * moderation -> censor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * upgraded jquery to 1.10.2 + cleanup
  * implemented menu.db-delete to remove corresponding menu-item data from the database
  * added delete-fn
  * handler for menu item deletion
  * remove menu item from dom on successful deletion
  * new spritemap
  * use dev pem in dev again...
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * avoid logging sensitive information in production
  * now there is REALLY no logging in production for requests ; )
  * add papertrail shell script for watching app logs, ONLY FOR PRODUCTION ;)
  * use production pem in prod, (need to use symlinks for this and use logic), decrease timeout in case of dos attacks (testing without cache reveals this problem)
  * Merge branch 'master' of github.com:khoerling/powerbulletin into prod
  * Revert "load socket.io from right url in lazy-load"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum.slug is just the basename
  * add authorization urls for Matt's blitz.io accounts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * work on fixing focus bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * improved error checking & ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make sure dbid is set correctly in menu.extract
  * + reap binary
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * delete wip
  * misc. comp style
  * added @build-nested-sortable to recursively draw site menu in admin
  * load socket.io from right url in lazy-load
  * added dbid to admin menu
  * report errors better on failure
  * added some error handling to menu.db-upsert
  * updated docs in shared/forum-urls.ls regarding moderation log
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix an ie bug
  * ++Sales
  * admin ui & sales page build-in ++
  * only run bin/powerbulletin in production (faster)
  * added reap & reaping /tmp every 30 minutes
  * disable optimized build in production, it is messing up load order -- needs some tweaking
  * hopefully fix shim config
  * add env to bin/build-requirejs-optimized
  * standardize on strings for menu-item id because nested-sortable's to-hierarchy uses strings for ids
  * no need to require other libs
  * surfing is fixed in IE9, had to use the html4+html5 history.js bundle instead of the html5 only one
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix socket.io in IE, ie still broken but console exceptions cleared on IE9 (click handlers for anchors arent working)
  * menu.upconvert(old-menu, id-fn)
  * comment spacing
  * ability to resort menus (rough)
  * stub for server side of resorting menus
  * removed accidental mutation from menu.struct-upsert; added more docs
  * added docs for move; removed reorder, because move can handle that case without extra work
  * implemented menu.move in terms of @item, @insert, and @delete
  * made menu.insert not mutate original menu and fixed splicing bug
  * fixed bugs in menu.path and menu.delete
  * admin menu supports up to 3 nested now and misc.
  * fix: don't always show profile photos (left nav)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added menu.item and menu.delete helper functions
  * fixed bug in menu.reorder for handling case when old-n > n
  * new post action buttons and then some
  * fix: oops, fat-fingered jquery cookie
  * + new default avatar
  * offline development working again
  * misc. ui bundle
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + spritemap
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added menu.reorder function (for special case of move operation)
  * provide place to store optional database id for menu items (different from nested sortable id)
  * uncommented upsert
  * misc. menu-to-comp.
  * improved Sales <head>er
  * shrunk scroll height by ~15% for shorter resolutions
  * More sales ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + new favicon
  * moderation log wip at /m, fix race condition bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix a buncha race conditions
  * fleshed out rest of state table
  * check in moderations page wip
  * fix repl
  * some refactoring, avoid repeating things twice
  * some small stylistic tweaks, hide all modules by default, add a second module for Site editing
  * fixes undefined header Access-Control-Allow-Origin and sets it to '*'
  * update jquery to latest point release of 1.x branch, cdnify several urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add the full plethora of cache domains to the window
  * finesse
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * checkin wip SuperAdmin component with first child module 'SuperAdminUsers'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sales page ui *bomb*
  * new animation on sales page & better build-in
  * fix realtime search for initial page load
  * Cache-Control: no-cache for search page
  * remove one round-trip due to an ssl redirect, make socket.io delivered files able to be delivered from muscache
  * necessary to get grunt working
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * compile js and run requirejs optimizer in production
  * tune bin/develop, bin/diediedie, and bin/launch
  * background-image -> <img> and more ui
  * dropping design bombs, working through a couple ideas...
  * fix: hide reply drawer when creating a new post
  * fix: io-server/pb-rt crash
  * header ui: search, scrolling, etc...
  * more cleanup (app)
  * grunt working with bin/develop
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * earlier bits, beginnings of ui greatness
  * Merge branch 'requirejs'
  * made pure-validations compatible with both plv8's require and amdefine
  * build script to build optimized sales app bundle
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * sales app works with requirejs
  * forgot to pass site-id to user-fields in u.top-posts
  * Merge branch 'master' into requirejs
  * make 3rd party logins work again
  * these keys were for mma.pb.com
  * Merge branch 'master' into prod
  * commented out upsert functionality in resources for now; res.json success: false instead of next err to prevent crashes
  * added menu.upsert for upserting various menu-item types
  * tweaked menu.extract function
  * edited function comments
  * removed dead code; wip on menu saving
  * added menu.find and menu.path
  * blue color defaults for sales + comp.
  * fix: footer correct width in admin mutant
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * adapted menu.extract and menu.mkpath to new reality
  * layout+++ (more comp.)
  * auto focus first input after selecting AdminMenu type
  * more pager cleanup
  * don't export insert-statement, update-statement, and upsert-fn
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.pages.upsert and db.forums.upsert
  * using stylus variables for color, etc...
  * recombining AdminMenu forum with nested sortable
  * playing w/ tag colors
  * use variables for tag colors
  * Merge branch 'master' into requirejs
  * fix: fix: better disabled this way
  * temporarily disable pager
  * latest design bomb
  * fix: wide-style left content again w/ avatars
  * resize footer to left-content
  * all stylus colors in variables
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * pulled in prelude here and there
  * ignore elastic-logs folder
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * split SocketApp into its own process pool (so now we have app, cache, and socket pools, and additionally the indexer and the search notifier
  * saves menu & active form (one-at-a-time)
  * wip for making sales page work w/ require.js, too
  * undo patch to nested sortable for .data() attributes
  * ui flow: hiding & showing admin menu type
  * Merge branch 'master' of github.com:khoerling/powerbulletin into requirejs
  * notify when we are testing http cache, sleep a bit longer before launchning appserver in dv mode
  * cache /socket.io/socket.io.js for 1 year by fixing up the headers in varnish -- also setup cache-blowing via project changeset
  * tweak bin/diediedie and bin/develop to be more courteous with mon
  * overhaul mon/daemonization process, use one uniform technique to figure out how to kill old mon instances which does not involve pidfiles
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into requirejs
  * re-structured with beppu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip on saving menu
  * upgrade elasticsearch to 0.90.3
  * automated in chef adding symlinks for the plv8 procedures and the elasticsearch config
  * nodejs recipe overhaulin
  * misc. forum ui
  * disable unit test for photocropper (was broken)
  * disable unit test for photocropper (was broken)
  * Merge branch 'master' into requirejs
  * fix: correctly store textarea & checkboxes
  * fix: keep saved titles
  * fix: json.parse if array or string
  * active ui for admin menu type (up top)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * admin menu cleanup & ++
  * admin menu ui mostly working!
  * added active ui for selected admin menu item
  * playing with hashtag padding and borders
  * fix indentation mistake, whoa don't know how i missed that lol
  * fix private site mutant
  * Merge branch 'master' of github.com:khoerling/powerbulletin into requirejs
  * more chat fixins
  * fix some bugs on the profile page
  * renamed first param of mkpath so path lib not shadowed
  * add uri attribute to menu-item nodes (similar in spirit to forum.slug and forum.uri)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed bugs in recursion
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * an experiment in recursing through site.menu.config
  * admin menu save/restore wip
  * configure cache-busting with requirejs, EASY, DONE
  * - jquery.deserialize
  * fix optimized build for legacy stuff, client-jade needs to get loaded after component-jade so that it takes over window.jade.templates (argh i hate global crap)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * saving new object-style form data
  * tweak tweak
  * re-swizzle bin/diediedie
  * Merge branch 'master' into requirejs
  * install requirejs (so we can use the optimize script)
  * support for optimized builds in prod now, works, share config in one location for requirejs
  * change top-right profile pic when user and uploader are the same
  * fixed drag and drop profile uploads
  * authorization guards for /resources/conversations
  * hoist env to window so its uniform on both server-side and client-side, fix search, fix another bug where  was assumed global so required like we should
  * fixup unit tests since file location changed
  * remove some console logs
  * couple bugfixes for drawer, ck-submit-form _has_ to be on window
  * bin/develop script as stopgap to replace browserify flow
  * admin bugfixes
  * Merge branch 'master' into requirejs
  * it seems that the sales app is still intact, I am going to leave it alone for now with the headjs config, so we can do this requirejs factor in smaller pieces
  * more bugfixes for main forum app
  * fix admin -> domains initial load
  * use the correct post-count
  * latest wip
  * fixed db.posts-by-user to not return too many results
  * comments work
  * can now create thread with requirejs branchg
  * need to think about server side menu data more
  * fix thread pagination
  * homepage/forum/thread pages all work
  * Merge remote-tracking branch 'origin/master' into prod
  * more tweaks, now all that is left is mainly global cleanup
  * oh snapz, varnish was cutting off the stylesheet at 5s before stylus could complete (~8s), this fix should greatly improve static file reliability in addition to the other fix, but this one is safe enough to cherrypick into master @smurf0r and it should help alot
  * start weeding out global manipulation, fix another bug
  * worked around mutant sloppiness for now (mutant was referencing our client-jade templates directly)
  * shim in all our jquery libs
  * check in latest WIP
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * converted more libs to use @
  * converted client/tasks.ls
  * removed console.warn \avatar
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * whoops; this is the socket.io profile pic change
  * resolved conflict and added socket.io profile pic updates
  * + .tiny-grow
  * site-specific stylus using cache-buster!
  * -> livescript 1.2.0
  * factored cache-buster into server helper
  * Revert "use regular domain for site stylus"
  * + logo icon
  * cleanup stylus
  * reduce deadline to 1500 on io-server
  * fix pb-cache launcher so it launches both nodes now
  * Merge remote-tracking branch 'origin/master' into upgrades
  * fix: hide profile/summary on new post
  * layout cleanup
  * sales page design bomb
  * cache-buster for avatars
  * teach require.js how to require mutant
  * more progress
  * upgraded npms: express & cheerio
  * upgrade to node v0.10.16
  * headjs restored
  * Merge branch 'requirejs' of github.com:khoerling/powerbulletin into requirejs
  * cache server now has probe
  * generated by livescript 1.2
  * converted client-helpers to not use export to get around requirejs issues
  * isolate cache server to its own process, this will increase reliability
  * hoist max-age up higher so both express.static servers can use it, and restrict .ls files from being served, ever
  * cleanup git history a little by using back-calls for amd definitions
  * images up on sales page
  * AdminMenu misc. & notes
  * checkin latest wip, next on the chopping block: lazy load code
  * fix: post drawer only collapses on success
  * fix: lazy-load fancybox
  * server-side of menu saving (stubs)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check to see if email already being used during @register
  * admin menu wip for beppu
  * everything loads, now just need to shim in a few more things
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: stylus cache url + misc.
  * let Auth.require-login and Auth.require-registration take callbacks
  * more wip, almost got everyting mapped over
  * install amdefine
  * require wip, following down dependency chain
  * remove livescript dep on appserver, beginning of using require instead of browserify - wip
  * update LiveScript and prelude: npm install LiveScript prelude-ls
  * latest sales page
  * improved scrolling functions
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * @profile-avatar // changes to error responses for debugging
  * Merge remote-tracking branch 'origin/master' into prod
  * admin wip, working on save/restore
  * misc. ui
  * be consistent with 1:1 ratio when using gm.resize()
  * Merge remote-tracking branch 'origin/master' into admin
  * added autosize
  * profile photos are circles + updated default aspect 1/1
  * fixes for left-nav/admin & footer drower behavior
  * Merge branch 'cropper'
  * install graphicsmagick via chef
  * route for cropping profile photo
  * fix the time bug
  * use site_id to constrain search results
  * Merge branch 'master' into cropper
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * introduced global.env to allow client and server to check if dev or prod in a consistent way
  * use regular domain for site stylus
  * admin menu wip
  * use regular domain for site stylus
  * Merge remote-tracking branch 'origin/master' into prod
  * Revert "pb owns public/site folder (for admin styles, etc...)"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: clear varnish on style change & cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pb owns public/site folder (for admin styles, etc...)
  * use correct domain during site creation
  * Merge remote-tracking branch 'origin/master' into admin
  * guard tooltip unless msg
  * save jcrop object correctly
  * Merge remote-tracking branch 'origin/master' into prod
  * configured jcrop to be able to handle images bigger than window size
  * Merge branch 'master' into cropper
  * don't hardcode domain for cors requests
  * don't hardcode cacheUrl in component/SalesLoader.jade
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into prod
  * made test a little more loosey goosey until we can add some less brittle testing for unit tests (thinking use cheerio to make assertions rather than raw string matches)
  * building more content & style
  * guard for chatty subdomain input
  * now using transit for hardware accel!
  * setup Jcrop in crop-mode
  * admin save wip
  * switch to crop mode after upload
  * a couple unit tests for PhotoCropper
  * Merge branch 'cropper' of github.com:khoerling/powerbulletin into cropper
  * check in profile / avatar / cropping refactoring crap
  * more work in progress
  * static css in production
  * Merge branch 'master' into cropper
  * add notes
  * give more time before kill -9 processes, more graceful
  * be smarter about purging varnish on deploys
  * set +e when killing workers in case they aren't online
  * deploy fix, launch before starting workers
  * deployment tweaks, try to deploy with minimal downtime
  * autologin after register and don't force verification
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sales enhancements for emkel
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added a query dictionary in pb-models for queries that don't need to be stored procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * caching tweaks for sales app
  * caching tweaks, add changesets to urls from sales app, and to stylus sheet
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + ssl bundle
  * Merge branch 'master' into cropper
  * add production domain to domains table for auth reasons
  * point cdn urls to correct location
  * add mma fixture for production domain
  * sales page+++
  * Merge branch 'admin'
  * admin menu saves & renders initially
  * show Login by default
  * test-prep script for codeship
  * split tests into unit and zombie, run unit tests on each deploy
  * doh
  * deploy hotfix for new secure port
  * fix search pagination, put 'from' in the right spot
  * fixed css for .PhotoCropper .button
  * Merge branch 'master' into cropper
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create and save new random verification string before resending verification email
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * sales page++
  * always run onload-personalize
  * Merge branch 'master' into cropper
  * whoops notate in s instead of ms
  * beginning of unit test suite to flush out bug in elapsed-to-human-readable.. haven't found 'bad' value yet ... ; (
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * glossed tooltip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ability to resend verification email
  * Merge remote-tracking branch 'origin/master' into admin
  * design bomb dropped on sales page
  * admin wip, deserialize/serialize
  * + lazy-loaded jquery.deserialize
  * lazy-load sets body.waiting
  * button hover animation
  * snapping together post drawer & post edit/new
  * button hover animation
  * snapping together post drawer & post edit/new
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't allow unverified users to log in
  * Merge remote-tracking branch 'origin/master' into admin
  * added post reply to bottom of every forum page
  * Merge branch 'master' into cropper
  * allow (new PhotoCropper).start to be called with 0 args again (livescript trick)
  * small documentation correction
  * work in progress
  * Merge branch 'search'
  * recency is not factored in reasonably into boosting
  * too many params; put in hash and use default vals
  * simplified PhotoCropper.start
  * Merge remote-tracking branch 'origin/master' into admin
  * menu admin wip (saving nearly done)
  * misc. ui
  * fix: require login for reply drawer
  * disable non-working tests because they need to be fixed
  * thinking about implementing distinct upload and cropping modes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * launch 3 nodes in production on ports 3000-3001
  * only enable photocropper on your own profile
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: reply dialog ui
  * never cache probe
  * prep node with a probe url + varnish prepping for load balancing can handle up to 10 nodes right now (ports 3000-3009)
  * Merge branch 'master' into cropper
  * make varnish respect cache-control: no-cache
  * really really hotfix prod this time
  * elasticsearch security (tested on prod)
  * git ignore tweaks for prod
  * production hotfix, until uglify issue is worked out for sales bundle
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: for save handler
  * Merge branch 'master' into cropper
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * dont provision on deploy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: mutant static crash & cleanup cl
  * style bomb on control button
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * homer says doh
  * force all /auth/* routes to no-cache
  * codeship.io prep
  * ze cropper shows up
  * admin wip
  * only show submenu if exists & delayed dropdown
  * checkin wip for search recency
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into cropper
  * added "cleanup" to bin/powerbulletin
  * fix: sales stylus
  * prepend instead of append new posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest stylistic tweaks
  * Merge branch 'master' into cropper
  * fix: don't crash on general admin initial mutant load
  * Merge branch 'master' into cropper
  * cleanup: pruned ckeditor & bits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add fixture for powerbulletin.com
  * Grunt: exclude Components from minify, cleanup task & create -sales.min, too
  * forgot to pass site-id to u.top-forums
  * removing some console.logs from socket.io code
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: master.styl -> master.css
  * Merge branch 'sales'
  * use new tooltip.styl
  * Merge branch 'master' into search
  * extracted tooltip styles into own file; added it to master-sales.styl
  * Merge branch 'master' into sales
  * fix: re-align paginator
  * added site_id to db.top-posts and db.top-threads
  * upgraded grunt
  * fix: only refresh if privatesite
  * if err, log it before exiting in presence.ls
  * build uris for new sites in fixtures
  * set path for 'chats' cookie
  * prevent db.usr from crashing when it gets bad data
  * make user-for-session more robust
  * added site_id to db.posts-by-user
  * added site_id to db.post()
  * added domain for site_id 7
  * - transient user profile (again)
  * fix: show/hide search input cancel
  * misc. ui
  * fix: hide scroll rails on search page
  * fix: hide/show paginator between mutants
  * Merge remote-tracking branch 'origin/master' into search
  * Merge branch 'master' into sales
  * update zombie
  * Merge branch 'master' of github.com:khoerling/powerbulletin into search
  * last-minute ui tweaks
  * Merge remote-tracking branch 'origin/master' into page-bottom-post
  * chat tweaks and fixes
  * post drawer saves!
  * removed console.warn
  * 404 when /user/:name not found
  * History.back! when mutation xhr fails
  * Merge remote-tracking branch 'origin/master' into page-bottom-post
  * Merge branch 'chat'
  * remember and position chats
  * fix: posts per page used on profile, too
  * fix: reset paginator when leaving profile mutant
  * fix: reset paginator when leaving profile mutant
  * fix: posts per page used on profile, too
  * snap chats to footer
  * remember open chats in cookie named 'chats'
  * Merge branch 'master' into page-bottom-post
  * mutant warn instead of error benchmark info
  * search zombie test
  * update zombie
  * some tweaks to streaming algorithm, my butt dyno says its alot smoother now and loses no realtime events (he he i'm sure someone might prove me wrong but heres to hopin)
  * attempt to increase precision of streaming algorithm and improve robustness
  * show new hit count at top of search results page with effect
  * no auto-reload required as all is handled by mutations fore real-time ticker (to actual post) other tweaks also...
  * tweaks: step into my time machine, darling
  * hoping this tweak will prevent 'leaking' realtime events on accident in some cases
  * allow efficient version of reload except in 1 case (same page), use internal indexing timestamp for streaming elasticsearch instead of created (which was based on postgres timestamp)
  * pagination should be ignored for realtime search, it now is
  * added emkel user & judenfrei fur beppu fixtures
  * fix:  .search, too
  * moved total hit counter back into body among other fixes...
  * fix: 2 breadcrumbs?  weird...
  * misc. search style
  * breadcrumb style for searches, animation down, etc...
  * Merge remote-tracking branch 'origin/master' into page-bottom-post
  * merged.
  * checkin search visual wip
  * npm install gm #graphicsmagick
  * transient cleanup
  * remove jcrop and html5-uploader code from profile.on-personalize
  * Merge branch 'master' into cropper
  * initialize reactive variable window.r-socket as early as possible to avoid race condition
  * working on save
  * Merge branch 'master' into cropper
  * typo s/process.id/process.pid/
  * split out replies & comments (less confusing)
  * fixed z-indexes for new drawer
  * drawer++
  * thread paginator style tweaks
  * Merge branch 'master' into admin
  * Merge branch 'cropper' of github.com:khoerling/powerbulletin into cropper
  * drawer expands/collapses & top-level replies nearly working
  * add endpoint-url parameter to PhotoCropper
  * checkin wip PhotoCropper component
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * new search result notification now is clickable to show new results, perhaps store id's of new posts for next pageload in History push-state so they can be highlighted?
  * Merge branch 'chat'
  * Merge branch 'chat' of github.com:khoerling/powerbulletin into chat
  * Merge branch 'master' into chat
  * fix crash in search-notifier
  * fix crash in search-notifier
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * changed .post .body line-height to 1.5 so text didn't looked so crunched together
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleanup paginator after leaving forum page
  * Merge branch 'master' into page-bottom-post
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui++ and bounce const for beppusan
  * increase t-step to 100
  * merged
  * don't need jquery-history-native anymore
  * upgraded history.js
  * hashtags and at-tags in posts
  * fix: "no method render-mutant"
  * general admin saves site name
  * Merge branch 'master' into chat
  * changed class to .time-title
  * added comma to disambiguate function call
  * Merge branch 'master' of github.com:khoerling/powerbulletin into sales
  * modal fancybox (never close!)
  * Merge branch 'master' into chat
  * made chat be prepopulated with past messages
  * db.messages-recent-by-cid
  * kill all content containers, auto load login dialog & cleanup!
  * made time-updater know about .data-title
  * increase timeout for first chat message
  * POST /resources/conversations calls db.conversation-find-or-create
  * use proper reload instead of location=
  * Merge branch 'master' of github.com:khoerling/powerbulletin into privatesite
  * doh how did i not see this
  * improve documentation, be more anal and make sure homepage is never cached upstream for private sites
  * header & main menu++
  * cover all cases where we need to _not_ cache if the site is private
  * photos & online/offline ui++
  * small fix but toggler still busted
  * let there be private parts. fixed the syntax error
  * remove dead code
  * reload page on login, for private sites to work
  * initial ui state, ready to load & save!
  * cleanup
  * Merge branch 'master' into admin
  * upgraded stylus
  * personal site basics in place, just need to tune and test, also need to popup login dialog for private site by default? .. does login window.location on login cuz it needs to for private sites?? maybe??
  * Merge branch 'master' of github.com:khoerling/powerbulletin into privatesite
  * animations++
  * ignore pb.sql
  * Merge branch 'master' of github.com:khoerling/powerbulletin into privatesite
  * Merge branch 'master' into admin
  * reworked profile/tools menu in header & tamed animations
  * saving wip
  * fix: crash on static load
  * lazy load socket.io
  * ignoring /public/sites
  * merged.
  * Merge branch 'master' into chat
  * non-component css using .main-content & .left-content classes instead of ids
  * bandaid for crashes + transient removal
  * ignore pb.sql
  * removed some log messages
  * stacked signal handlers
  * menu admin wip (before battery dies)
  * persisting chat info in redis instead of process memory
  * show err.stack before graceful-shutdown
  * big merge
  * ui+++ & cleanup
  * merged.
  * wip: better admin style error handling, verbiage & ui
  * site-specific css can be stylus now!
  * + new defaults & cleanup
  * users can save their own site-specific css
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * fix crash and rip out more transient business
  * added Auth.require-registration; require registration before making site
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * private site prototyping... wip, at least the page loads hehe
  * animations++
  * fix: don't cut off last thread in left nav
  * font is back
  * merged -- looks good
  * initial wip for posting at the bottom of each forum page
  * fixed u.user-fields and procs.forum_summary
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * create_site now requires user_id and doesn't care about transient
  * set session cookie value to old 2-item style
  * pruned transient from ui
  * Merge branch 'sales' of github.com:khoerling/powerbulletin into sales
  * more transient cleanup
  * require-login before site creation
  * Merge branch 'master' into sales
  * Merge branch 'transient_cleanup' into sales
  * Merge branch 'master' into sales
  * added header and ability to login/logout from browser
  * jumbo menu admin update
  * remove console log
  * reset threadpaginator to active-page:1 when changing forums
  * merged w/ matt's static/initial refactor
  * refactoring of render-component to make it more elegant to use... prep work for yet another component i'm adding (thread paginator)
  * misc
  * close on client-side w/o waiting for server response
  * if node gets a SIGINT, clean up socket.io connection info stored in redis
  * Merge branch 'master' of github.com:khoerling/powerbulletin into transient_cleanup
  * woo pagination stopgap WIP... just need to plop view in for left threads
  * modify top-threads so it takes offset and limit, show top 25 threads and hook up paginator.. now just need to make clicks point at something ajaxy
  * Merge branch 'master' into chat
  * fix regression where click handlers weren't always working due to the clever trickery we are doing on the forum/thread pages
  * on-page handler tested and working for Paginator, update unit tests, now need to hook up index/offset to top threads retrieval
  * backup/restore scripts for postgres to make it slightly less painful (not having to scrape again if no schema change)
  * thread paginator WIP
  * render-component requires now a toplevel identifier name (can't always assume classnames are exclusive)
  * Merge branch 'master' of github.com:khoerling/powerbulletin into threadpaginator
  * refactoring of render-component to make it more elegant to use... prep work for yet another component i'm adding (thread paginator)
  * Merge remote-tracking branch 'origin/master' into admin
  * <form> privacy and more ui
  * fix: test fancybox when lazy loading
  * on-personal for admin
  * improved scroll rails
  * + profile image & mutant link in header
  * dropping another design bomb
  * pull down & focus search on header click
  * Merge remote-tracking branch 'origin/master' into admin
  * removed some debug code
  * made profile photos work
  * Merge branch 'master' into chat
  * Paginator tests wip, gonna add click handler capability for paginators which are not url/mutate based
  * don't redirect ssl when dealing with Zombie.js user agent
  * Merge branch 'master' into chat
  * update zombie
  * varnish and haproxy always live on port 80 and 443 respectively regardless of whether dev or prod, this makes testing with zombie easier (local dev + zombie tests can be used at same time)
  * update mocha
  * update test to reflect new output of Paginator component
  * login tests (wip)
  * removed most of cruft from passport, probably a few things left, tested can log in and post
  * Merge remote-tracking branch 'origin/master' into admin
  * checkin latest changes, various style tweaks, reorganizing sales process to 86 transient_owner
  * cleaning up site registration
  * Merge branch 'master' into chat
  * s/isInt/is-int/
  * try this
  * attempt to avoid the crash when clients try to reconnect a little too early
  * Merge branch 'master' into chat
  * fix pagination on profile
  * misc ui fixes and then some
  * async grunt 'css' task works + cleanup
  * Merge branch 'master' into chat
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make sure db.posts-count-by-user takes site-id into account
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * automated schema dumping script, if we skip the migration aspect for now we can easily use commercial tools to sync the database structure, and keep the schema in git... a sort of stopgap between now and when we have time to hack on migrations
  * typo
  * forgot to pass in site.id
  * incorporate site_id into conversation* queries
  * Merge branch 'master' into chat
  * - cssmin & cleanup
  * 2x stacked search header wip
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use pre-generated stylus in production
  * refactor building stylus into server helpers
  * forward port so i can use pgadmin3
  * Merge branch 'master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * send email when a subscription is purchased to sales@powerbulletin.com
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * vary purchase message for fun
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * holy hell, pagination works on profile page, man that was a bitch
  * crash under all environments equally + debounce
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: "on-file" works on the first purchase
  * added bao and reef.powerbulletin.com and conversations.site_id
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * adds slight margin for wide displays
  * placeholder for flat/nested forums
  * adds slight margin for wide displays
  * simplified presence.users-client-remove by requiring a user param
  * authorization phase was blocking cookieless requests from making successful socket.io connections
  * always call presence.leave-all on disconnect
  * only emit leave-site message if user has no more connections to the site
  * introduced redis key "cids:#{user.id}"
  * use redis transactions for enter and leave
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make bbcode allow both uppercase and lowercase tags
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleanup last buy component before creating new
  * Revert "think i fixed bug in production"
  * Revert "fix: buy works again"
  * menu admin wip
  * added Creative & Engineering product
  * re-organize admin nav
  * fixed add-commas
  * for /user/:name/page/:n, if :n is not an int, next err (non-fatal)
  * if the err.non-fatal is true, no graceful-shutdown happens
  * make express-validator available to all routes (not just personalized ones)
  * fixed a broken join in db.posts-by-user-pages-count
  * Merge remote-tracking branch 'origin/master' into admin
  * fix: buy works again
  * menu wip, working on css radio tabs
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * kill mon, too
  * fix regression
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * factor paginator stuff into reusable function
  * Merge branch 'master' into chat
  * pass presence into ChatServer
  * Merge branch 'master' into privatesite
  * think i fixed bug in production
  * made io-server and io-chat-server use debug
  * Merge branch 'master' into chat
  * converted auth to use debug lib
  * make pb-models use debug lib
  * make thin-orm accept an alternate logger
  * Merge remote-tracking branch 'origin/master' into admin
  * powerbulletin now watched by mon in production
  * + debug
  * made realtime site presence work again
  * Merge branch 'master' into chat
  * use presence.ls in io-server
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added regexp
  * make the constructor's cb send back this
  * Merge branch 'master' into chat
  * return an error if we get a bad cookie
  * vim fdm=indent
  * Merge remote-tracking branch 'origin/master' into admin
  * comma'ify + widen search facets (for thousands)
  * Merge branch 'master' into chat
  * Merge remote-tracking branch 'origin/master' into admin
  * fix: search static crash
  * fix: mutant.run for on-initial when initial mutant exists
  * misc. ui improvements
  * forgot to delete rooms:#{cid} on @leave-all
  * Merge remote-tracking branch 'origin/master' into admin
  * added more presence functionality
  * added mike for ui feedback
  * fleshing out beppusan's presence
  * Various preparation for private site & addition of purchase hooks - added hooks for product purchases - added private to multi-domain middleware - re-tool layout-static so it is called with params as this - populate site.config.private on purchase of private site
  * - older socket.io (using top-level everywhere)
  * + redis & hiredis
  * Merge remote-tracking branch 'origin/chat' into chat
  * cleanup paginator after leaving search page
  * draggable working, wip ...
  * Merge remote-tracking branch 'origin/master' into admin
  * + footer scroll to top
  * mad layout, search & paginator love
  * only bench in production and more logs
  * Merge remote-tracking branch 'origin/master' into admin
  * - more client logs
  * Merge branch 'master' into chat
  * removed console.warns out of Auth.login-with-token
  * s/authorize-by-login-token/authenticate-login-token/
  * sketching out api for presence
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * - broken admin menu link
  * menu admin wip
  * let them be admins of their own sites
  * after registering a local user, cb back a user object with the new user id
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into auth
  * after new site creation by registered user on pb.com, Auth.login-with-token!
  * added "reload" to Component
  * make auth-handlers.once-setup use GET
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * me and beppusan hackathon for linking transient users to registered sites
  * disable/enable submit button
  * handlers for login based on auth.login_token
  * auth.set-login-token user, cb
  * db.authorize-by-login-token
  * merged everything up to this point
  * misc. admin ui
  * universal Component render function
  * whitespace
  * if logged in to pb.com and new site is created, create alias for current user on new site
  * db.alias-create-preverified
  * building ui...
  * admin-menu -> yacomponent::AdminMenu
  * added "reload" to Component
  * Revert "factoring conversations out of chat among ui enhancements"
  * Merge remote-tracking branch 'origin/master' into admin
  * invite only 100%
  * misc. ui tweaks
  * fix: forgot swings down again
  * fix: error handling & feature: resends verification email on error
  * if non-transient site created, redirect to \#once
  * reorganized middleware for sales-app; non-transient site creation possible
  * added aliases.login_token to db
  * Merge branch 'master' into auth
  * Auth.show-register-dialog! (for matt)
  * misc ui
  * add subscription tampering to config save and then some
  * renamed product: private_site -> private
  * cleanup before implementing matt's shiney new varnish config
  * rewire varnish to cache even requests which have a Cookie in the request
  * redirect tested successfully, now just need to wipe transient sites before test starts as a prepare measure
  * private site wip
  * another bomb on admin frontend
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * finally! escape from symlink hell when using npm install in /vagrant on vm
  * install zombie: headless testing
  * layout ui++
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: catch masonry crashes
  * update yacomponent, fix typo
  * frontend for privacy and invite only, and then some
  * fix: no more "blank" errors
  * replaced inline handlers with onclick-buy, using data-product='foo'
  * editing tooltip
  * factoring conversations out of chat among ui enhancements
  * fix: load fancybox on the first click
  * b00m fix the transient user bug, can now be logged in as soon as you hit the site, now need to tag team global login with beppusan
  * really check ui for subscription
  * misc. fixes and ui
  * analytics working
  * headjs = head.js
  * Merge remote-tracking branch 'origin/master' into admin
  * Merge branch 'master' into auth
  * fix: using site.id instead of user's id
  * fix syntax error
  * fix: config json crash
  * working on analytics & subscriptions
  * misc. cleanup & style
  * fix: credit card validations working w/ matt earlier
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay, i can make cors requests.  now what?
  * remove commas
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove transient user from client code, keep it server-side
  * Merge branch 'auth'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * uniq'd
  * Merge branch 'auth'
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * lazy load fancybox everywhere!
  * clean-out initial load dependencies
  * more wip
  * using head.js for autolo'je instead of jquery.get-script
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * checkin wip, regular users now always override transient users
  * npm install cors
  * fix: restart gracefully
  * io-server has new auth for transient
  * check in latest wip
  * authorize transient users in deserialize-user
  * look at process.env.NODE_ENV (not just process.env)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make graceful-shutdown reload when it's done
  * new user serialization handling in io-server
  * ready for more admin!
  * Buy dialog lists features and then some
  * new schema & fixtures for product features
  * Merge branch 'auth' of github.com:khoerling/powerbulletin into auth
  * changed user serialization format for passport
  * checkin wip, pass down transient_owner id to user object, wip to handle in serialize/deserialize exclusively
  * added pb.com to domains fixture
  * Merge branch 'auth'
  * finished integrating auth into sales-app
  * chat+++
  * added lazy-load-fancybox() and switch-and-focus() to client-helpers
  * fix: eat draggable click
  * pulled in animation css for sales-app
  * show-tooltip comes from client-helpers
  * Merge branch 'master' into auth
  * setup up middleware for sales-app
  * the beginnings of chat bubbles
  * profile ui fix and gradient main menu
  * Buy submits with return key, disable/enables ui and then some ...
  * Merge branch 'master' into auth
  * moved switch-and-focus to component/Auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * crash fix
  * PB Sales is #1
  * Merge branch 'master' into auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default scrape-mma to site-id 2
  * adding auth dialog to sales app (wip)
  * + jcb image
  * added jcb card and then some!
  * misc.
  * added error handling + tooltip to Buy
  * improved mouse enter region + images
  * added ccv security info and then some
  * + product: super compute instance
  * + diners club card
  * fix another regression, can now once again buy a subscription
  * fix regression where placeholder values were submitting, and fixup serverside code
  * prime-number pricing fixtures
  * added new cc images
  * prime number pricing
  * admin++
  * dropped a design bomb on the Buy component
  * fix regressions on signup process -> transient owner.. now to fill in holes in their user experience
  * pull Component out into its own library yacomponent, and leave only our domain-specific code in component
  * setup as dependency, and install yacomponent
  * fix indentation typo / improve look and feel of AdminUpgrade
  * AdminUpgrade component now disallows buying subscriptions which are already purchased (subscriptions must be passed in)
  * oops checkout needs to always be there
  * Buy component now uses button instead of ParallaxButton
  * enable person to enter different card details even if card saved on file
  * moved the has_stripe logic to where it belongs, on the site object (which correlates to a user)... since a super can subscribe a customer if they have already entered card details (or even if they haven't, they can enter them for them)
  * blank card details is now interpreted as blank card, and hence will then default the customer to their last used credit card
  * fixed Auth.show-info-dialog
  * fix: after login, do!
  * separated invites from forgot
  * added info dialog to auth
  * - outline in nav (ff & ie)
  * fix: load the requested admin page on initial
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't need attach; empty!remove! to remove chat
  * changed method names; no longer need to prefix with 'chat-'
  * moved ChatServer to app/io-chat-server.ls
  * merge conflict
  * guard against media_urls longer than 2000 chars
  * user.hasStripe fix
  * added stripe keys to prod (just testing for now)
  * commit wip for saved card details (once we've been given a card once)
  * fix regressions
  * fix: only submit once with keydown
  * fix: clear ckeditor value after use
  * more cleanup ...
  * forgot password shows activation notice + improved error handling
  * fix height on login and footer opaque
  * only instantiate window._auth once
  * cleanup when chat disconnects wip
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ported choose to Auth::choose
  * node_modules/passport-twitter/.npmignore deleted
  * changed default value of users.config to {}
  * upgraded passport-twitter due to twitter api v1 being deprecated
  * ported toggle-password to Auth::toggle-password
  * ported show-reset-password-dialog to Auth.show-reset-password-dialog
  * fix: reusing channels
  * Merge branch 'master' into auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * auth++
  * Merge branch 'master' into auth
  * add more checking to make sure we don't try to subscribe twice
  * it works i say
  * apply beppus thin-orm fix
  * cleanup dead/un-needed code in Component
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * various component tweaks, payment subscription wip
  * rotate strength meter right-side up
  * common js / jsu refactor
  * admin & buy ui and then some
  * misc. button styl
  * fixes + lazy refactor
  * ported forgot-password to Auth::forgot-password
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * place holder buttons for buying custom domain and private site
  * ported register to Auth::register
  * ported login to Auth::login
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * admin upgrade section added, for marketing fluff about upgrades
  * fix: crash in admin
  * Auth::open-oauth-window
  * pimped-out fancybox with secure logo
  * yay, remove componentName from properties in component, now inferred from class name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * payments.subscribe now handles both cases, can change card at any time
  * misc. editing stylus
  * fix: misc. crashes
  * inline editing saves w/ user feedback!
  * moved ch.require-login to Auth.require-login
  * pass entire editor object
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * moved show-login-dialog to Auth.show-login-dialog
  * better lazy loading of complexify
  * total monthly cost now calculated based on subscriptions colun
  * add subscription_total stored procedure
  * wip payments, a subscription is now added subscriptions table when you buy something
  * removed handlers from pb-handlers.ls that had already been moved to auth-handlers.ls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in wip
  * Merge branch 'master' into auth
  * erge branch 'master' of github.com:khoerling/powerbulletin
  * stop when we've loaded all previous messages
  * stripe init script
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * form + inline saving working!
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * further streamlined ckeditor plugin
  * loading previous chat messages (wip)
  * inline ui for replies
  * auto focus first reply
  * don't send if message is blank or all whitespace
  * messing with stylus for chat.
  * gave a default width for embedded images
  * allow false values to be set in an UPDATE via thin-orm
  * fix: crash on cleanup
  * misc. footer style
  * editing working better & cleanup
  * fix: only update textarea when ckeditor data
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * misc. ui
  * footer rises after 2.5s on initial load
  * pager back to showing if >= 2 pages
  * move presentation concern into presentation layer
  * changed behavior of paginator to be empty unless pages > 1
  * since paginator is inline items in a div with auto height, it didn't need display:none, it dissapears all by itself
  * small refactor
  * only show pager when more than 1 page and cleanup
  * reply working & big cleanup
  * save button working!
  * user-friendly errors
  * Merge remote-tracking branch 'origin/master' into ckeditor
  * cleaning up editing code, moving toward a ckeditor-unified strategy
  * some guards
  * + lazy load
  * open links in chat window in new page
  * sanize chat input
  * don't crash when there's no @post
  * universal PagerTron, deploy =D (look at footer)
  * ckeditor wip
  * posting tooltips & validations
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * layout ui ++ && cleanup
  * chat.load-more-messages (wip)
  * set data-message-id attr for both sender and receiver
  * pass on message id in chat messages
  * fix: a couple issues from domain -> subdomain and then some ...
  * sales page++
  * pulled out control style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reload all jade templates on -HUP, too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * started a resource for conversations
  * trap server.close errors and cb!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * one less div nested in output
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reuse the paginator component, but lazily initialize it also
  * faster watch
  * removed some console.logs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * persisting chat messages
  * allow mass assignment of locals to component
  * locking down more critical behavior of Component
  * whoops fix ngramming
  * make app/search.ls recognize page param
  * paginator in better shape now
  * took advantage of new behavior in component to shorten code
  * don't blowup with an exception, just silently ignore attach/detach unless @is-client
  * change step size in correct place this time lol
  * pass in correct step size, still brokenz, will get to the bottom
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + pbsave plugin for ckeditor!
  * search tweaks, paginator feels pretty good right now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix server-side renders
  * - save plugin
  * Merge branch 'master' into auth
  * provide window.siteName to Auth.jade
  * added siteName
  * pull in Auth Component style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. ui tweaks
  * included Auth component
  * factored out regexps so they could be shared between pb-handlers and auth-handlers
  * fckeditor + save plugin - about
  * use the routes from auth-handlers
  * lazy load complexify js and render Auth component in show-login-dialog
  * made Auth into a real Component
  * fix regression / tests
  * paginator is now rendering on client mutations only and i'm not sure why : \ but it works.. will figure out rest later wip
  * latest stylus
  * Merge branch 'master' into auth
  * add some more safety, so we can't set reactive functions and we will know what the problem is
  * go full hog reactive with paginator
  * whoops missed a small bit of cleanup
  * tweak Component so you can now specify locals _as_ reactive functions, thus reducing complexity and leveraging reactive programming, see Paginator for small example of this
  * latest tweaks, can now assign with local method, and there is now an init method which is for component init
  * fix a regression and tests
  * add auto-attach powers to Component, make paginator anchors mutannts
  * more tests
  * fix a bug in paginator, start writing unit tests to cover all these weird cases
  * shading ...
  * checkin Paginator wip
  * Paginator is somewhat correct now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * checkin paginator wip
  * don't output @ -- to much noise
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reorganized chat server code
  * manually reload socket.io on @init
  * pass conversation.id in message
  * re-balance common
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * force pb-worker-* to stop on ^C
  * added password strength meter
  * tag pages with classes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add Paginator work in progress
  * password show/hide toggle on register + choose password dialogs
  * register shows all errors + cleanup
  * killall -r pb-worker
  * Merge branch 'master' of github.com:khoerling/powerbulletin into preempt
  * Merge branch 'preempt' of github.com:khoerling/powerbulletin into preempt
  * preempted
  * moved fancybox css after head and further layout rice
  * preempted
  * pruned old on-personalize
  * left nav threading much cleaner
  * preempt main, wrap into ServerApp class
  * - nospawn
  * turn the Gruntfile from js to coffee
  * don't make watched tasks depend on watch
  * lazy load css, too!
  * lazy load js for loggin-in users and admin
  * + misc style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + sceditor (inline coming!)
  * fixed another join in posts-by-user
  * missed a spot
  * forgot to check this in; - instead of _
  * use - instead of _ in chat event names
  * db.posts-by-user was joining the wrong table in one query
  * cleaned out public/local
  * fix: race a couple conditions w/ History & click handlers
  * fix: guarantee only 1 browserify, even if multiple grunt procs
  * fix: no more corrupt browserify bundles
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * re-re-added interrupt:true
  * chat (work in progress)
  * fleshing out menu admin ideas ...
  * sharper common elements
  * left column admin no-longer resizable and then some
  * doh forgot the library
  * create pure wrapper for cc-validator-node
  * npm install cc-validator-node
  * add necessary ui fields to accept credit card details
  * doBuy('custom_domain') and doBuy('private_site') work based on db models, now to crack out on checkout process
  * add resources for products, only need show for now
  * add test routine to payments lib
  * forgot the notes i added to schema =D
  * two new tables, purchases and products
  * Revert "to be safe, lets pass the cookie only to the domain where it is needed, and avoid possibly leaking secrets to the wrong people"
  * to be safe, lets pass the cookie only to the domain where it is needed, and avoid possibly leaking secrets to the wrong people
  * menu admin beginnings
  * refactoring auth into component/
  * factored out auth routes into separate file
  * fix regular posting
  * update validations to not be retarded
  * plug security hole
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed it, but no admin access for /admin ??
  * tools menu sync'd with transient
  * @beppusan see if this fixes your security concern
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * payments api, it begins, mwa ha ha
  * consistent transient defaults from models to views
  * guard against transient logout
  * mutant now only marshals non-void values
  * fix: bail out on profile if none exists
  * first pass & literature to sales app
  * signature flair
  * fix: misc. crashes
  * npm install stripe
  * misc. style
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + source flair
  * fix: break for /new editing (so history has time to update url)
  * r doesn't always exist
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * emit correct post count on thread-create and better error handling
  * allow non-transient users to post again
  * invites working!
  * + is-email
  * post.user_id XOR post.transient_owner
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * the button going beyond the left edge of the screen annoyed me
  * more fixups, one last one is eluding me (for reply ui)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * beginning of a reusable sql fragment generator for the transient_owner shim, i need to do about 4 more fixups but they can all share the same js string template
  * made scraper work again
  * whoops forgot image
  * added future owner default image, and remove extra / from user photo in threads
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * posts from future owner now show up in thread list, and has defaults for future owner name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added ability to choose a username after confirming invite
  * user_id is now nullable on posts
  * remove extra character that was typod
  * insta-site-creation w/ redirect works, now to hook up the transient_owner cookie with /auth/user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create general forum by default on site creation
  * i believe this will fix the gruntfile
  * - warning
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create-site procedure now works, can take a user_id or not, returns transient_owner identifier if no user_id passed in
  * misc. ++
  * improved error handling + re-sends invites if re-invited
  * name-exists proc takes email instead (+ refactor)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add transient_owner TEXT field, will store random hash identifying owner, if owner hash + site matches, then we auto-login them in as admin in /auth/user
  * use cookie in sales app, sales app is now pb.com instead of sales.pb.com
  * latest
  * live keyup availability check (red or green checkbox to verify)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * availability checker for sales
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * needed to contrain get-cols a bit more
  * moved specifically client functions outside of shared helpers
  * helper refactor
  * another pass on admin/invite, and then some!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added minimize && thinking about socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added send-message(ev) method
  * fit the textarea into chat box more snugly
  * fix: show correct tooltip even after error
  * ported what exists of Chat to new Component system
  * fix: global.
  * merging...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * stylus now on sales page, other tweaks, gruntfile fix?
  * this is why i dislike putting json in csv
  * notes for systematic refactor of main.ls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove unused file
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * pages now single-column w/ transitions in & out
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a fixture for pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * set class to page
  * return of the interrupt
  * help cursor & moved layout bits there
  * silly matt, load your stylesheets always before your javascripts ; D
  * css loading superpowers
  * load up all js stuff properly, integrate layout.ls
  * create file which will keep track of remote js urls
  * latest tweaks
  * separate out loader component, hope to share layout.ls with it
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * pages route and mutant
  * page handler
  * more sales fuddling
  * updated Buy ParallaxButton and SalesApp to conform to new Component
  * configurable auto-render, dont auto-attach
  * update component tests
  * latest component lib with reactive integration and now need to setup children in constructor
  * some refactoring
  * make it so that children returns an object instead of a list for easier referenceability
  * allow specification of locals as 0-arity funs 'lazy vals'
  * make Component.ls compile with -k
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * rename SalesLayout -> SalesApp
  * working toward invites, need to auto create users next
  * refactored to use new email helper
  * bootstrapped SalesLayout and Sales components for sales app
  * oops forgot app/sales-app.ls
  * sales domain added
  * integrate attach into render phase
  * subsequent renders now work as expected (backed up with test)
  * render does not render children on first pass (instantation of child handles this)
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * parameterize on-click for ParallaxButton component
  * window.do-test demonstrates how a component can easily take-over an arbitrary selector (in this case 'body')
  * more polish, fix tests
  * major overhaul of Component, took suggestions from john, treat dom as first class and remove need for unique classes by scoping everything
  * added initial help/forgot to auth dialog
  * fix: production boots!
  * parallax button component works now, js and all
  * Merge branch 'master' of github.com:khoerling/powerbulletin into component-experimental
  * fix regression with Buy
  * fix regression with Component.ls
  * fix bin/diediedie
  * skip creating dom (optimization) unless mutate phase or children are defined
  * various tweaks
  * wrote test for nesting
  * refactor Component and update tests, pulled reactivity out, that can be a sub-class later, wanted to KISS for now
  * added pages table and removed trailing spaces
  * misc. ui++
  * fleshing out admin email invites
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored email into helpers, ready to use for admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * implemented chat.add-message and changed spacing between chat windows
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * now using site.current_domain for email from:
  * maintain a hash of chats and don't allow more than one to the same user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: only purge varnish if censor happened
  * censored posts retain permalinks, etc...
  * reorganize chat windows on close
  * fixed my .Chat prepending bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * john should be like butter now let me know
  * separated #chat_drawer from footer
  * fix: guard censor from crashing node if called multiple times
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more debounce
  * fix: sort media urls to top of site & forum summary
  * fix: using e.target instead of "this"
  * source maps only in dev mode
  * refactoring of jade bits, build jade with debugging in dev, compressed in production
  * move window.mutate into client-helpers, fix one last regression for browserify hopefully
  * - reduce the global headache by creating a module named client-helpers - fix regressions after browserify + grunt regressions - grunt works AMAZING now ; )
  * Gruntfile tweaks to watch components / be less annoying in dev mode
  * source maps / latest browserify / fixed merge regression
  * resolve merge conflict
  * misc. ui style
  * consistently default posts per page to 30
  * censored posts show up in profiles + new censor style
  * yay browserify works + we have source maps w00t
  * fix: don't crash if posts blank (guard blank ui input)
  * fix: don't crash if no varnish bans
  * start of invites admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Chat uses matt's components
  * update browserify
  * post owners can censor their own posts (and admins)
  * + require admin middleware
  * fix: re-enable submit button on success
  * summary model clean up, favoring media_url & starting to build homepage views
  * window.do-buy
  * build component jade templates, add to grunt, also start of 'Buy' component
  * - fix regression replace-html doesn't work quite right... - Component tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add Component library i've been hackin on, a HelloWorld example, and accompanying test framework
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. css
  * fix: user check
  * added aliases.config json field
  * redirect to homepage on logout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * facets feel pretty cool right now ; )
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * you now see live facet updates as you type, and they go away when they no longer provide any selection
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * laying out stronger data foundation for homepage & forum homepage
  * latest tweaks, update filters on every statechange since there is more going on now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum facet items now link to filtering on that facet
  * don't scroll when clicking footer
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Chat skeleton (wip)
  * commit wip of forum facets, need to switch to ids and map to forum name with hashmap (can be done server-side)
  * fix regression where replace-html was not being called when searching because not in scope
  * convenience script to reinit elastic from scratch
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * facet on forum title, wip, see SEARCH.TXT for example, will integrate with ui next
  * all mutant static using replace-html
  * fixed pagination math
  * reflect search in tittle
  * latest tweaks to search, fix some history regressions, add nice benchmarking if we wanna use it (in pb-mutants) only used in search mutant now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * homepage showing data with new, faster query
  * fix regression, search bar filled up again
  * fix regression
  * use raf only if mutant has split out prepare/draw phases .. if draw phase is too slow we get frame dropping
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made title and meta tags show up on static loads
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * page titles
  * disable form submissions until success or failure + tooltips
  * fix: really ban profile pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * search mutant is fully riced with raf, last bit to optimize is layout-static (split into two phases, first phase produces data, second phase consumes+updates dom)
  * testing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ban profile pages when posting
  * fixed 3rd party oauth logins
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed local user registration
  * add backwards compatible prepare/draw phases, existing mutants don't have to adopt it but can, renders longer than 16ms are errors on the console
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * try this keith
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * raf is now automatically used for render-mutant, while not anymore in the large case
  * use requestAnimationFrame polyfill with mutant, fix bug in mutant where we were running the mutant.run callback handler 3 times
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * spacing
  * first pass on re-thought homepage
  * remove console.debug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only render profile's left_container if not same profile
  * use generic surf data (should be set to forum's, profile's, etc...) instead of specific forum-id
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * let the existence of @top-threads decide whether we render the left-nav or not
  * removed pick function (not used anymore)
  * clear varnish after scraping
  * bumped media_url to 2,000 chars
  * partial for chat box
  * change argument order to any()
  * disable password reset input elements
  * finishing touches on forgot password flow
  * much better reliability with filters, can't rely on hints for now
  * more querystring beautification (no more lonely ?), hopefully fix bug where leftbar wasn't rendering at the right instances by using current instead of last hint
  * small performance tweak
  * cleanup code and make a little more readable, also keep bullshit out of the querystring (also fixes repeating = bug)
  * save and edit replace url instead of pushing (as they should) will get rid of dangling edit and new urls in history
  * fix initial pagelaod of /edit too (allow cookies)
  * fix: forgot hover/arrow
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * I forgot your password.
  * some visual tweaks for filters
  * can now reply directly from a search page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * decorate thread hits and comment hits
  * pager .current draggable now snaps
  * show all forums on forum_id filter
  * on enter change to search mode, but if on search already, soft submits can also send queries
  * hey /new called, and wanted its cookies back
  * hook up within in app/search
  * add ui side of time filter, need to tweak app/search now to receive within paramater
  * reset search state after leaving search mutant so filters don't come back from the dead
  * don't reload leftnav on search
  * various tweaks to search to allow empty querystrings (filters only) also notify user of overly-restrictive terms
  * make app/search aware of new querystring parameter forum_id, various other tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * beginning of left filter controls, reactive-style
  * + u.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * style back on all .close'ers
  * removed prelude from procs & profile page loading
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip search, searchopts passed all the way thru, one unified interface for realtime + frontend query
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot password part 1 of 2
  * searchopts working uniformly w/ notifications and frontend search
  * refactored save-stylus into model
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * run middleware correctly on /resources/*
  * always generate main.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * conditional cookie
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forgot to call cb
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed main
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * updated main.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * relying on set-timeout to keep the right global visible
  * updated readme regarding firewall rules
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * automatically populate thin-orm via information_schema
  * broader hover region
  * downgraded console-trace
  * prelude working with new require \prelude-ls + beppuhack
  * updated cheerio, async, livescript, console-trace & express-resource
  * another pass on homepage, looking better and faster-er
  * cleaned up closers and search clears
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * setup thin-orm for some tables. mixed in to pg.procs for easy access
  * oops-- fixed homepage, too
  * fix: select active top & child-level main menu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ban varnish urls in admin when appropriate
  * added fields param to db.sub-posts-tree
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * guard against going beyond last page in pager.set-page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes close / admin overlap on search input
  * expose some pager functions for debugging
  * this is barely an orm so it's ok
  * hack fields onto top-posts-fun so that it propagates to sub-posts
  * fix nice scroll rail
  * trimming homepage
  * a bunch of layout ui fixes & improvements
  * make thread title show up in comment hits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * convenience for scraping a buttload
  * added mma.pb.com/site.css generated from fixtures
  * when mutating away from a search page, leave search channels
  * join search channel on initial pageload, work around raciness with reactive =D
  * scroll-to -> onclick-scroll-to
  * now scraping media_urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added media_url to posts
  * really fixed my regexes
  * bumped title length
  * ok yay, no keypress steals AND back/forward events exclusively are the only thing which will override the query box (that and fresh page loads)
  * slight regex changes
  * only show each 3rd-party auth on login if setup in admin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added more rice to search, don't needlessly do dom update pushups if someone really smashes those forward/back buttons
  * sprinkle animations
  * improve nicescroll
  * prune unused code, slightly less frisky with soft searches
  * improve scraping so-as to remove annoying apple.png/droid.png which is littering my console ; )
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: syntax issue
  * yo search box.. lol give me back my capital letters
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * soup up search, doesn't steal keypresses anymore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass on domain-specific stylus
  * made db.usr() able to query for users by email
  * unarranged user fixtures to remove spaces
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added aliases.forgot and updated fixtures
  * .scroll-to-top -> onclick-scroll-top
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: guest users have socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only personalized routes need a giant stack of cookie middleware ; )
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unicode support in post slugs
  * fix: nicescroll rails stay in place
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * html symbols back and no-longer pulling jsdom in runtime
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * UTF-8!
  * cheerio working on all mutants
  * + cheerio
  * cheerio set to default & working on forum mutant
  * shrink browserify bundle on client
  * scrollable tweaks and then some ...
  * beginnings of site-specific stylus for admin
  * native scrollbar-less, hardware-accel scrolling for left nav
  * main menu, homepage & layout ui cleanup
  * conditionally profile:  export NODE_PROFILE=1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * npm install git://github.com/bnoordhuis/node-profiler.git
  * latest prof changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * first pass at stored procs for private messaging
  * tools drops down with better mousing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * search ui++
  * npm install git://github.com/sidorares/node-tick.git
  * profiling in dev mode, and script to parse v8.log
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: paginator tooltip should always appear
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reactive.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added mon do die, so:  ./bin/diediedie; ./bin/create-pg && ./bin/launch
  * extra validation for email & user name on register
  * added the concept of conversations
  * npm install git://github.com/mattbaker/Reactive.js.git
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tables for private messaging support
  * shrink css bomb
  * tooltips on login/register!
  * show-tooltip helper
  * fix: really use posts-per-page site config
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added .tooltip.right to paginator indicating active page
  * admin authorization -> domains
  * don't forget to do simple optimizations for forum <-> non-forum surf transitions
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * removed a console.warn
  * reduced # of prod workers to 1
  * added private key to pem for automatic load
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * haproxy production hooked up with prod.pem
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * minimize async.auto tasks for inter-@forum surf requests
  * added tooltip + save indication to admin
  * guard post edit for ownership
  * guard admin for domain ownership
  * beginning of search shim, has an option for streaming which will hook right in with search-notifier
  * fix logic bug in varnish ; )
  * small correction in anal-ness for regexp
  * don't depersonalize urls ending in /new or /edit, don't cache 404's or redirects
  * + ssl bundle
  * oops, didn't mean to prune this
  * make indexer more informative on console about init/startup, tweak batch-size up some, make idle wait a bit longer
  * add script to tail postgresql log + indexer and notifier daemons in one console
  * remove internal header now that things are working gravy
  * start of a tooltip and more
  * keeping cacheUrl only
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic surf data minimization for non-forum mutants
  * fix: twitterConsumerValue -> twitterConsumerSecret
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got it!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: syntax issue
  * removing surf data minimzation from server-side; planning to move to client
  * surf data minimization functions (wip)
  * fix:  site -> domain
  * admin authorizaion saves & defaults
  * + comma key for triggering search
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more admin style
  * admin-general reads & saves!
  * admin -> admin-general
  * fix broken parse function; needed parens
  * added forum-uri to metadata returned from parse
  * w00t, add fields to search, give post fancy view to search hits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add debug logic to figure out where human readable time is brokenb
  * part of merge?
  * merged etag headers
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * scrolling left nav. again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * purge forum page on post update
  * initial scrollable + mousewheel & mods.
  * fix: don't crash when personalizing mutant
  * entire thread clickable on left content
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * prefill posts-per-page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * invalidate threads when creating sub-posts
  * abbreviated created fields
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * s/update-site/site-update/
  * time based caching for frontpage and forum urls
  * cache homepage for 60s in production
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * the big caching patch, wip need to add some more invalidations so we don't end up with stale content
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * local login needs to lazy load passport, too
  * added posts.is_locked and posts.is_sticky to schema
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * can has touch this?
  * provide default avatars; still need to dig out avatar info from 3rd party if available
  * passport lookup is now lazy
  * replace ALL the phone icons
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * do a better job of removing those annoying iphone/android icons for phone posts
  * hammer time
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * if there is no page var, provide a default internal dom for #paginator
  * fix: homepage data
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * typo postsPerPage
  * highligt the right h3
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. profile & homepage enhancements!
  * new tools menu
  * another pass at /admin
  * automagically expands left_container if collapsed when mutating into /admin
  * fix: oops, need to be more specific  :)
  * site.config.posts-per-page
  * fix: show avatar on profile replies
  * domain -> current_domain
  * fixed domain-related procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * put keys in domains.config instead of site.config
  * script for modifying a row in the domains table (with config support)
  * added domain-by-id and domain-update
  * added .onshiftenter-submit and mutant-specific .onclick-submit handlers
  * Merge branch 'master' into domains
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * let /socket.io give us cookies; only let /auth set cookies
  * show created date on wide left nav & only hover for narrow
  * intelligent logout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: mutant callsback on-personalize
  * more layout depersonalization for admin, login, logout & profile
  * removed --domain option from bin/site-config
  * added domains.config and updated fixtures
  * surf data minimization (work in progress)
  * guard stored procs
  * fix: homepage sorting crash
  * auth saving wip
  * guards
  * posting ui++
  * hacking on admin
  * new tools menu: admin, profile, logout and layout improvements
  * fancybox & login++
  * fleshing out /admin/authorization
  * dropping another ui bomb
  * added style for blockquotes
  * experiment with making thread-create an event on $ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * task differencing work in progress
  * same thing for non-prod config
  * remove dead/nonworking code, should be fine without
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * various varnish tweaks + gzip fixed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * paginator animates show & hide in sync with left_container
  * refactored handle into layout and some nav style
  * fix: resizable must run on initial load
  * minor cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hide first post on pages > 1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: post_edit -> post-edit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: env for search
  * refactor: underscores to dashes in filenames
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ignore user images
  * res.vars refactor
  * + admin_nav
  * ignore public/images/user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * moved verify to /auth (for depersonalization)
  * beginnings of /admin
  * don't need fdoc.pages anymore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * /user/:name/avatar changed to /resources/users/:id/avatar
  * procs.usr can now find users by id, too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added admin to depersonalize
  * secure client cookie
  * fix: keep passport session cookie
  * simplify depersonalize logic
  * Merge branch 'prod' of github.com:khoerling/powerbulletin
  * pass NODE_ENV thru sudo
  * whoops, correct condition for not installing elasticsearch twice
  * don't depersonalize urls matching ^/resources
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * increase debug-info and reap intervals, remove TODO which is complete from comments
  * misc. style boost
  * working on reply dialog and then some...
  * fix: more reliable order
  * merged!
  * experimenting with jcrop
  * added jquery.Jcrop plugin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed behavior of cancel button in edit view
  * add logic in varnish to depersonalize all cdn urls regardless of url
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * randomize search-notifier work interval, DEPERSONALIZE all but ^/auth and ^/admin in varnish
  * only set up the uploader on YOUR profile
  * add title of last post to realtime widget
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in search wip, now shows a div which updates saying 'new search results'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * html5uploader from profile pics
  * added change_avatar(usr, path)
  * installed mkdirp
  * try to fix keiths bug
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * realtime search hit updates WIP -- update/delete side handled by existing system when implemented, just need to unify search interface now between socket.io and frontend ajax
  * added tab to search blacklist
  * really run on-personalize
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * banning keycode 87 from initiating search
  * personalize static loads
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * subtle pager theme & handle
  * fixed bug where disconnecting would not remove one from a room
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * reaping pollers works
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * w00t, rooms work without socket.io-announce
  * dash vs camelCase
  * profile page+++
  * fix: left-nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * s/pageCount/pagesCount/ typo fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * deal with window resizes correctly in pager
  * whitespace
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added jquery html5 uploader plugin
  * moved the logic for showing pager controls to one function
  * trying to fix production
  * invert my logic
  * merged!
  * set-page can optionally not manipulate history
  * added forum + user context to profile pages like reddit
  * parse-int to the rescue
  * fixing more pager bugs
  * fixing many pager bugs
  * previous and next page via arrows; bare minimum seo
  * if the surf request failed, bail out
  * hide footer completely by default
  * fix: set min-width higher for left_content
  * default left_content to wide view + simplified cookie
  * next-mutant & prev-mutant refactor + search history
  * after creating a new thread, mutate to it
  * draggable page indicator
  * default font to sans-serif (just in case nothing else matches)
  * misc. fixes
  * search ui++ and then some
  * paginator only shows when there's more than 1 page (hides by default)
  * more login and layout stylus
  * human time has bolded numbers
  * oops, also mutate when clicking for context thread on profile
  * possible to reply on profile & forum pages now!
  * paginator accomodates triple digits vertically & sped up main menu animations
  * added enter to search ban list
  * showing thread context on profile page among other enhancements
  * another paginator/left-nav ui pass
  * added spacebar to blacklist
  * fix:  "surfData is not defined"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * auth + paginator style
  * slide in new posts + moved form submit into helpers
  * more accurate math for pager click behavior
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tune up caching for production on static resources to a 1-year ttl (we can depend on the cache getting blown on each deploy)
  * our not-so-graceful shutdown (force shutdown after 5s)
  * made user profile paginate
  * added db.posts-by-user-pages-count and made db.posts-by-user page aware
  * warn instead of log so access log is not polluted
  * merge conflict resolution
  * take advantage of jquerys automatic normalization with it.which
  * timing + guard
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc. pager + main menu ui
  * scroll to active thread in left nav on initial load
  * re-enabled key logging for when search is triggered
  * bi-directional communication can't be done thru client :\ not sure why.. but with server-side + clientside we are complete without announce
  * turn off immediate mode (so we can see benchmarks of how long routes take)
  * tune up the thresholds in spinner slightly, also make slight tweak to algorithm to make it more correct
  * make bin/diediedie more frisky, mon-ify indexer and search-notifier
  * add mon recipe
  * create wrapper to daemonize search notifier
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * install socket.io-client
  * wip query poller, requires socket io client
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * prevent double-posting of the original post
  * removed even/odd in jade
  * changed us into super users
  * use @forum-id instead of window.active-forum-id
  * only pager.set-page if we have a valid window.page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * merged!
  * fix: mutate left container by default
  * cursor pointer for #paginator
  * moved #paginator and added #left_container
  * initialize pager on forum load
  * require pager
  * hook up History.push-state into pager
  * Merge branch 'prod'
  * massive style bomb, working on homepage
  * added _post_profile partial & consolidated all profile photos
  * Pager class
  * fix: homepage orderer shows back up after mutating away
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * homepage / forum homepage switch between resize & not
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * spinner tweaks
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add socket.io-announce to repl
  * Merge branch 'master' into prod
  * Merge branch 'prod' of github.com:khoerling/powerbulletin into prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix fancybox flash
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * waiting cursor override anchors etc so people know mutation is taking place
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added reset dialog for beppu
  * re-align edit dialog (centered)
  * loading cursor yay baby
  * re-align edit dialog (centered)
  * raise the rate-limit threshold
  * continuous stager now pushes to prod
  * test again
  * test
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check for development mode more accurately
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added access_log for development
  * cssmin breaks stuff
  * fix:  now able to fresh-load edit urls
  * megamenu++
  * inject.js has to be http
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wrong cdn urls for prod
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * really hide paginator
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * changes to help make it work on prod
  * hide paginator
  * mutant states simplified (no longer tracking last in separate variables)
  * thx to beppusan the great, we now have a namespace for procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove host vars, add cache domains to static config
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * replaced db.forums() with db.forum-summary()
  * found stray hardcoded site-id; fixed with 2 joins
  * user pb in home /pb
  * resolved merge conflicts
  * style bomb, mostly addresses posts & child posts
  * fix: main menu active
  * onload-layout-resizable factored into layout itself
  * fix:  oops, default to not refresh left_nav
  * added surfing data to mutant & hooked up to forum mutant
  * .? -> ?
  * responsive++ among other spacing/leading tweaks
  * don't kill indexer on diediedie
  * first round at a megamenu and also more crisp theme
  * global helpers in repl
  * initial forum homepage view and then some
  * responsive js layout + breadcrumb
  * misc. css for post head & title leading
  * + responsive.styl & wide nav view
  * posts structure+style +++
  * edit/reply can happen simultaneously
  * show/hide #order for specific mutants
  * better handle forum backgrounds
  * edit post working _much_ better
  * first post aligned with left nav
  * main menu always clickable as z-index on submenu falls behind
  * last-mutator on window + cleanup to use it
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make db.post return tags also
  * fixed comments for add_tags and add_tags_to_post
  * associate hashtags to posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * symlinked prelude.js into plv8_modules/ directory
  * refactor with folds
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added db.add-tags(tags) and db.add-tags-to-post(post-id, tags)
  * search on blacklist (since we might have unicode) + re-org
  * _surf=window.mutator
  * oops, really ignore arrows
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ignore non-printable and arrow keys for search purposes
  * layout+++ and cleanup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only react to printable characters and backspace onkeyup
  * new thread cancel works & cleaner layout
  * when initializing elastic, initialize setting for pb (atempt to)
  * install superagent
  * fix:  real-time threads working in nav again  :)
  * style bomb
  * search wip, ellipse sidebar with css, resizing is a bit funky on mutation...
  * show hits in left pane too.. needs some styling love bad
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip, we now have custom search events which couple together keypresses + surfing for instant search
  * use varchar(16) for posts.ip instead of inet to try to prevent crashing
  * suppress output of git command
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * prevent add-post from crashing due to invalid ip addresses
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create 'search' event which is for now just mapped to keyup of the query box, it also passes the search params as part of the event args
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * another thing I forgot to check in
  * save the ip of the user who created the post
  * added null ips to all fixture posts
  * fix:  reply (post_edit)
  * added posts.id
  * fix emoticons when cache_url is overridden
  * homepage_forums takes 2 params now
  * + cleanup
  * refresh only when order changes and more efficient menu redraw for layout-static
  * run as normal user; will sudo for you when needed
  * forgot to check this in
  * security fix:  removed site tokens, etc... from surf urls
  * made db.homepage-forums take a sort order
  * moved html around for order controls
  * style for order control
  * added app/views/order_control.jade to jade.templates
  * order control template for the homepage
  * missed a spot
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleaned up & refactored all jade views, making partials out of everything and pulling them in separately:  partials denoted with _ prefix and everything that gets blasted by mutant + layouts without prefix
  * a script to launch everything
  * rebalance profile seo & add style
  * fix footer & left-column sizing
  * repl has shared + helpers merged into global
  * + shared_helpers.add-commas
  * homepage center, spaced & sorting nearby pagination
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resizing, breadcrumbs, cleanup & refactor states -> mutants for stylus
  * ngramming WIP
  * rudimentary styling and debugging
  * merge conflict
  * + merged beppu's changes & auth.jade
  * massive stylus refactor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * search interface returns json for no
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't crash when you don't have a profile photo
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix small indentation inconsistency
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Revert "installed simplesets"
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * the big fucking elasticsearch + indexing commit
  * make .avatar scale to left nav width
  * consistent main menu behavior
  * install elastical@0.0.11
  * added data-user-id attribute to div.profile
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * upgrade sync
  * distinguish between local and remote profile photos
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove archived field (unused) .. add index_dirty in its place
  * show posts by user in profile
  * adds container to profile for hiding content
  * force redraw of forum left nav
  * properly guard against installing elasticsearch twice
  * dropdown menus should be on top of left nav
  * installed simplesets
  * collapsed handle moves far out of the way
  * left nav is now below the header
  * fix refactor bug & re-aligned/spaced resizable containers
  * yearg jade
  * Merge branch 'before-node-upgrade'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * display info for profile in profile 'nav'
  * added .resizable class to posts.jade
  * load more data for profiles
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * hack to make browserify now work on latest nodejs etc
  * use .resizable instead of .forum to be more general; added layout-on-load(window)
  * + bitmap for sceditor
  * added views/posts_by_user.jade
  * TODO: capture profile.photo if available
  * added post_count to usr()
  * sceditor base css+theme
  * css cleanup
  * sceditor saving and looking good!
  * make usr procedure return more info
  * allow sp.user_photo to come from other domain in post
  * db.posts-by-user needs to be aware of site
  * less noisy logging of metatdata
  * really fix jsdom
  * update jsdom
  * upgrade to jsdom to 0.5.6
  * update geoip and bcrypt
  * console.log less metadata
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * nodejs update to 0.10.3, add elasticsearch recipe also
  * make . a forbidden character in forum urls
  * set-online-user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: switch and focus correct dialog for 3rd-party auth
  * io_server handshake
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * db.posts-by-user user-id
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * grab git changeset more reliably
  * + notice for graceful shutdown
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * - google font
  * added basics of scedit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use surfing for pagination
  * fix pagination to use mutant stuff
  * fix scroll-to-top & default to no search + expanded nav
  * add fixtures to expose pagination
  * only include said page, don't list previous pages (was for infinity)
  * + staging & personal testing aliaes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added domains table; site has-many domains
  * try setting longer timeouts
  * - require https (handled upstream in varnish)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix bug, one test now passes again
  * more css refactor
  * remove infinity, fixup testing
  * breadcrumb n-depth -- closes #17
  * only load test swarm+mocha+chai in dev & staging
  * standardize on jquery-1.9.1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made mutant links to user profiles
  * minor: changed param name for transition fn
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * massive css refactor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix css formatting for mocha =D
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * small api change in fsm; decided against varargs; just give me an array of inputs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add a test for mutating from homepage to forum
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * test push
  * fix bug where forum wasn't loading when a user isn't logged in
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fully configurable and overridable cdn urls
  * local settings were not overriding properly
  * allow config/local.json to override settings (not in version control)
  * accidentally checked in some debug code
  * point to correct injection url
  * make testing actually work (before it was not waiting for tasks to complete)
  * give mocha nice output for test swarm
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tests reliable / work now / muahhahahahahahahaha / and output is nice too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed post count issue in top-threads (i think)
  * subpost -> post refactor
  * make is-editing use the state machine
  * sh = shared_helpers; pbh = pb_helpers
  * parseInt the post id for the edit state
  * added socket.io to scraper for fun
  * removed stray console.warn
  * use fsm to make guards more precise; removed regexes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * commented out fsm.example
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * install mocha and chai
  * inline mocha tests (integration hack for browserswarm) in dev mode using mocha and chai (pass ?test=1 to url)
  * thread-permalink part may be string (not just number)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more metadata returned from furl.parse path
  * + add personalization to edit
  * comments working on parent + sub
  * provide forum_urls state machine and helpers as 'furl' in the repl
  * state machine for parsing forum urls with examples at bottom
  * fsm = finite state machine
  * guards for login/logout
  * + jessee user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * snap-scroll to newly created post
  * the light fix
  * Revert "unbork create-pg"
  * unbork create-pg
  * strings in pg should be utf-8
  * closer to being able to respond to top level post all the time
  * fixed create thread
  * realtime thread post count & cleanup!
  * margin'd comment body
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * monster update for realtime post reply & edit
  * css hackery to be able to hover over last post (for the case when we only have one infinity page)
  * got rid of console.logs
  * window.is-editing-regexp was not available on server
  * TODO - be more specific
  * realtime thread impressions
  * can view threads with 'new' in title again
  * layout+++
  * fix url popup for 3rd party auth
  * accidentally broke graceful-shutdown
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * I think app.close() may be deprecated, because it crashes
  * neater formatting of error message + stack trace + logged in user name if available
  * make /hello crash on purpose
  * fixed homepage template to show post.html
  * wip got mocha working (install mocha globally with -g on mac os x)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * tests with selenium wip+soda wip
  * body -> html (unescaped)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unsilence our error handler
  * + hello
  * really strip leading / after form cancel/save
  * dimensionsoftware.com -> beta.
  * thread update via socket.io (very rough)
  * left nav updated when new thread created
  * db.post() returns more data
  * fix duplicates bug on threads view
  * beginning of socket.io for creating threads
  * change default top-thread sort to recent
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * use post.html instead of post.body
  * added comment to add_post()
  * fixes for redis launch & window. scope in layout
  * flat parent threads
  * use redis store for socket.io
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * installed socket.io-announce
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * lean refactor for client/shared_helpers
  * add bin/launch-redis
  * left-padding on nav should be consistent through refresh & mutants
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * install soda
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored general code from entry into layout.ls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add script ot launch selenium, make selenium recipe require java 7
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix for .forum container
  * remove duplicate header since both haproxy and varnish set it (but only on haproxy side when tunneling thru it, varnish will still set header correctly if access directly)
  * scrolling behavior fully restored
  * breadcrumb and posts coming together
  * create thread working!
  * fixed off-by-twenty
  * footer++
  * initial mutant scroll-to-top smoother
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * new flush footer layout
  * load site based on damain instead of user.site_id
  * added postfix to chef recipe
  * fix merge conflict
  * admin wip, need to fix left padding for div #main_content
  * more add post wip
  * only scroll if page > 1 & hello using handler
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added validation dialog and then some for email activation
  * send empty errors
  * automagic login after verification
  * don't automatically login after successful registration
  * user verification route
  * added proc verify_user(site_id, verify_string)
  * fix: off-by-one
  * regex out iphone and android icons
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * always use error handler
  * fix missing info for toplevel post
  * guard when page has no pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix 404 case -- 404 only if a page > 1 has no children, page 1 is allowed to have no children
  * hopefully, edit-post and add-post still work
  * added functions h.hashtags, h.attags, h.html
  * make scraper able to pull more than 1 page of a thread
  * default to pb database in a safer way
  * added posts.html field
  * installed bbcode
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay bug is fixed, its a bit jumpy, but state-restoral is bueno
  * wip scroll to correct page when statically pointed to ?page=3 for instance, still bug where paginator is calculating page incorrectly
  * more realistic buttons
  * guard on no user
  * jump-to-infinite-scroll-point-by-page ; )
  * whoops fix bug
  * also update personalization for posts (ie add edit button) when infinity loads items
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * update presence when you scroll
  * more left nav finesse
  * res.json err in express/development
  * z-index bump
  * single post edit/multiple reply comments open at once
  * reply & edit working better (can have multiple replies, etc...)
  * adds db.owns-post + securely guards /forum/edit
  * default to pb db
  * refactored reply (comments) to use general post functions & jade
  * show active thread on left-nav
  * nav width more accurate on narrow/wide classes
  * + uglify
  * grunt now re-browserifies jade on change
  * move multi-domain stuff out of main and completely into multi-domain middleware
  * socket.emit \online-now on mutate
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleanup
  * don't fail when $NODE_ENV is undefined
  * added online-now message to socket.io server
  * moved users.rights to auths.rights
  * don't fail when $NODE_ENV is undefined
  * add new topic post wip
  * fix: edit working again ++
  * fixes:  left nav .wide class & ./bin/powerbulletin env missing case
  * pimped out breadcrumb & main menu
  * speed up provisioning by skipping ri/rdoc, fix typo in production json config, add user 'powerbulletin' as part of chef recip
  * oops needed one more tweak to point haproxy to the correct production endpoint
  * fix bug in both varnish and haproxy launch scripts where they weren't using the env var properly
  * prod conf for haproxy
  * beginning to verify edits
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove noise
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add aliases.verify upon registration
  * made auth available in repl
  * added aliases.verify and aliases.verified
  * added aliases.verify and proc alias_by_verify()
  * toggle .online class on .profile.photo
  * added animation to .online
  * paginator only shows if > 1 page & re-pulled in helpers for mutants
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * paginator guards & some style
  * .online css class to show who is online
  * fix: destructure crash now graceful
  * only show title if top-level thread
  * fix runtime error
  * nav has photo and wide-view default
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix: removed space from default input
  * breadcrumb working again!
  * function for generating registration verification string
  * common widgets++
  * paginator follows current page
  * fix merge conflict
  * software, shits hard
  * start of /new editable
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made /:forum work again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in wip paginator.. trying to detect visibility of pages
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * beginnings of a registration email
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic paginator control
  * fix: cancel working again on edit posts
  * fix cache_url thingy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make esc keep work when focused on input boxes for login box
  * entire edit cycle complete without surfing
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ok yay we have infinity scroll with templates
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * force reconnect socket.io after login
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip moving sub_post into its own jade partial, also split out mixins for reuse
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only load the right amount of pages, not into infinity
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic per-site presence
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more infinity tweaks
  * adds pb_helpers for shared entry & mutant code + factors out post editing to be more efficient
  * re-aligned menus & colors
  * added no-surf to mutant
  * sharper ui, common controls and added shrink animation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * local passwords now hashed with bcrypt
  * don't crash when user is not found
  * installed bcrypt (compiled module)
  * bug fix: responsive nav
  * comment out noise in serialize-user and deserialize-user
  * socket.io knows who you're logged in as
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * responsive left nav
  * add back part i needed
  * Revert "you are allowed to be a guest again! (bugfix) + wip all_sub_post_ids"
  * you are allowed to be a guest again! (bugfix) + wip all_sub_post_ids
  * posts edit and validate!
  * start segment at correct spot
  * tweak http-no-delay and forceclose accordingly
  * semantic change to haproxy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * socketio tweaks for haproxy
  * more on post saves, using generic .ajax form submit too
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * configure websockets + socket.io for pipe mode
  * notes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * working to edit posts
  * basic socket.io setup
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * posts/show resource (for editing)
  * installed socket.io
  * oops-syntax error fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * slimmed db menu
  * fix keiths bugs, re-init listview after mutation
  * dont rate limit in production, be more frisky, and finally lets not hardcode what we are pulling in
  * fix active-post-id
  * infinity dump the pages into the dom .. the live data in chunks of 5 top-level posts
  * 404 when on an invalid page, allow pagination of thread view (aka sub-post view)
  * fixed bug where subpost times were not being live updated
  * properly identify end of posts which can have more loaded, next need to add ref point for start of infinite load
  * improve performance, fix lazy init
  * load before they get to the end of the scroll, NEVER SCROLL TO THE END.. unless that is you are at the end of the forum
  * lost in merge
  * adds user photos
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed breadcrumb link
  * resources -> pb_resources
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * photo placeholder and misc.
  * refactor:  moved pb specifics to pb_, paving way for beer_, etc...
  * .editing class for posts & subposts (no longer cuts off inputs)
  * comments more obvious
  * register++ and working on main menu + breadcrumb
  * installed nodemailer
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * chef recipe to install selenium + soda
  * forgot to check in passport-google-oauth
  * change auths.id to decimal so google.user.id can fit
  * work in progress on google oauth2 login/registration
  * /auth/user shouldn't send an object containing sensitive auths info
  * automagically login after local registration
  * unique_name needed a site_id
  * added stored proc register_local_user
  * be more careful when blanking out input vals
  * proc for seeing if name already exists
  * local registration; could use more validation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip first mocha tests! bin/test
  * filled in @register route
  * wip of 'mocha-phantomjs tests/test1.html'
  * limit to 10 toplevel and 10 comments on toplevel posts
  * scroll to edit post position or top
  * permalink mutant
  * playing with breadcrumb position
  * isolated 'at bottom of scrolled window' event
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * put lodash in browserify bundle
  * added tags and tags_posts tables
  * suggest alternate alias names
  * auto close fancybox & -cl
  * adds correct create thread link
  * stubbed out /user/:name (user profiles)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * children posts & misc. stylus
  * generic form submit (using $.post now) & linked up to ui
  * 404 censored posts
  * gracefully handle the case where a  post is censored from the forum
  * reload on logout
  * no refresh needed on login anymore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * propagated site_id up the call stack
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * using on-personalize to properly bring out edit dialog
  * fix bug in children nesting on forum page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix bug in jade
  * u.sub-posts(site-id, post-id, limit, offset) // was just post-id before
  * fixes a couple ui issues and adds flush left nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix jade template for logged out (guest) users
  * run site-config outside of the loop
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * facebook and twitter keys for mma.pb.com
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add infinity to js sources
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * node 0.8.19 to 0.8.22
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * redis recipe with latest redis
  * main menu working better
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * misc.
  * more auth schtuff
  * default fake keys to prevent crash
  * twitter and google auth (untested)
  * using backcall
  * fix for popping up submenu when main menu is expanded in search mode
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * minor changes
  * utility script for changing a site's config
  * added and updated site related procedures
  * start of register function
  * added path to cookie
  * more transit embellishments
  * removed some console.warns
  * added sites.config for site-specific configuration
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added load-ui animations for smoother initial build-in and improved others
  * change username
  * mutate again.
  * moderation w00
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * WIP censorship ; )
  * facebook login/registration ++
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * css transitions for censor
  * bring in jquery transit 0.9.9
  * rights
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't crash due to not having rights
  * fix for .searching .submenu top
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * post censorship minus actual change of listing order
  * mark active subforum in main menu & only mutate left nav on subforum change
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more rice, use one script tag for marshalling
  * new and improved find_or_create_user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * don't crash onUnload
  * procedure for moderation 'censor;
  * fixture encoding errors fixed
  * super user privs for all the l33t guys in fixtures, add documentation for rights
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add rights
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored extra sorting functions out & natural default sort order
  * Revert "added auths.x_id which is a user_id from (facebook|google|twitter)"
  * spacing & leading on posts
  * finesse to login/forgot/choose username dialog and posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix thread page and improve error reporting for procedures when they are called with incorrect arity
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added "choose-username" dialog for beppusan and working on tumblr-style homepage
  * added auths.x_id which is a user_id from (facebook|google|twitter)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default sort is popular
  * working on nav & subpost
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a bunch of refuctoring to support different sorts
  * temporarily stubbed so it won't crash
  * work in progress on facebook auth
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * move mutant bits to layout instead of entry (also user auth which is a prereq for mutant.run)
  * mutants.js -> templates.js, removed from git, etc...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * automatically add _iso in addition to _human for adding dates, this way its easier to embed in data-time
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixes main menu padding
  * update time only every 30 seconds
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resolved merge for real
  * - powerbulletin*.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a little refactoring
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added forgot dialog and some other goodies to login
  * realtime clientside time counting
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * login dialog and layout.css refactored to theme
  * partial application baby
  * good stopping point
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * halfway thru cleanup of doc generation, just use sql unless there is a good reason not to for now ; ) main menu is the only common item i can think of to be cached so far
  * combined configs.
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * resize working again
  * custom error pages for varnish and haproxy
  * better crash prevention
  * update thread views on every load
  * add_thread_impression() to increment views
  * fixed fixtures to have default view counts
  * posts.views (for number of thread views)
  * killed dead code
  * added human readable dates to posts and nav
  * only redraw left nav on initial mutation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made it so that left nav doesn't change when mutating (hacky)
  * added username and post_count to thread mixin in left nav
  * added post_count to top-posts-{recent,active}
  * fix .advanced
  * improvements to inline editing & search filter ui
  * moderations added to schmea w/ fixtures .. also had to +e to get create-pg to work -- strange
  * latest tweaks, i had fudged up the varnish so now its fixed again, we need to implement nocache cookie for logged in users
  * varnish now has a white list for stripping cookies, looks for nocache cookie or for cdn domain urls
  * uri returns properly now from add_post, fixed reply dialog (was broken)
  * who keeps adding these to git lol
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * edit-in-place w/ jade & mutant pattern more fleshed out
  * add schema for moderations, create procedure for archive_post
  * fix merge conflict
  * add and use archive column for posts, actually remove the files from version control (bundled js files)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip inline /new/:id post edit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix uniqueness constraint so it actually works for uris, change add-post to try the pretty uri first and then fail back to the unique one
  * removed powerbulletin bundles from git & updated ignore
  * invalidate forum, some api safety netting for varnish init
  * convert add post to fancybox (easy) for now so I can actually use it
  * don't clip the last threads
  * remember better + using document delegate so handler isn't "lost in mutation" :P
  * handle collapses/expands nav
  * readying for beer. and additional sites wishing to use a mutant-powered layout
  * don't crash when cookie doesn't exist
  * added jquery.cookie (forgot to check in?)
  * ui auto saves & loads state across browser reloads!
  * lighter fancybox and cleaning up posts/subpost
  * expanded & scrolled states re-aligned
  * breadcrumbs in the right place; separated post & subpost + more style
  * kill with a whisper
  * Revert "updated geoip"
  * updated geoip
  * create abstraction where we hand cache.invalidate-forum an id and it does the rest
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactor one small part of protocol that was not documented (extra newline)... works better now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * left nav resize applies & cleansup with mutant states
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * default callback for varnish command
  * letting content break subposts and snapping it together
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * login & nav ui ++
  * stick the body on that callback too
  * a few more tweaks, be less greedy with cpu
  * w00t we got varnish native wire protocol now for admin interface in pure nodez
  * purge varnish script (without restarting varnish)
  * graceful shutdown to avoid malformed bodies with 200 responses
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * small refactor in vcl
  * scrolling works better & colors
  * misc style
  * loads local head.js in non production + mutant refactor
  * only use minified powerbulletin bundle in production
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * only kick off onPersonalize if user obj is not null
  * race fixed, yay
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a bit more
  * wip
  * wip
  * personalization in user urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * links up login popup, css & the resizeable left nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * simple css
  * merge conflict
  * onPersonalize baby
  * make html in body show up again
  * nested and toplevel subposts oh-my
  * fix bug in reply where it wasn't going to the right div
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * return uri instead of slug from add-post
  * working breadcrumbs and then some
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * merge
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add toplevel title and body to thread page
  * made reply-ui show up in the right place
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of infinite nesting of sub-post urls
  * davesan's password is 'davesan'
  * require-login should wait until the last possible moment (so this was too early)
  * added a require-login function
  * whoops, use site_id not id
  * associate added posts with currently logged in user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * allow cookies thru to resources urls
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * single quotes
  * merge conflict
  * various refactoring, + move threads_recent into its own doc that can be reused everywhere
  * killall before relaunching
  * shake fancybox on failed login
  * css3 shake animation - .shake
  * hooked up login form
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * icons for 3rd party auth
  * login form
  * window.user available via entry in client-land, looks at passport info from cookie on serverside at /auth/user
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * indent .children
  * checking pb changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * append reply ui more carefully
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * strip cookies like a madman
  * natural order for threads
  * resolved conflicts
  * use the right mixin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * varnish tweaks for stripping all cookies from most urls
  * grab bag of changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * recursively display posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactor varnish, fixed silly issue with not receiving ssl header
  * reply ui (basic hacky)
  * forceclose for haproxy
  * add threads now works from thread view
  * wip
  * task varnish with redirecting non-homepage urls that end with / to the non-/ ending version
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay show toplevel threads on thread doc / thread view
  * force post.build_docs to false all the time
  * made posts show up again
  * refer to sub-posts as 'sub-posts' for thread view
  * rename post-doc to thread-doc
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add debug route for sub-posts tree
  * build_docs key set to false leaves stale docs
  * maybe an improvement
  * fixed scraper (i think)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * conflict
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * guarded unload and misc.
  * redirect only on GET or HEAD requests so we don't do something silly (like redirect on a POST)
  * limit recurse depth to 3 by default for sub-posts-tree
  * and were back with super paranoid security, redirect loop gone, ALWAYS SSL!
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * haproxy + ssl is in, now to fix this gnarly redirect loop in varnish
  * shared cache domain for all vhosts
  * add guard to recipe so it doesn't repeat
  * recipe for haproxy
  * stunnel works woo, and varnish forces https
  * stunnel config and launch script created, also dev cert
  * varnish config syntax errors fixed, slight refactor
  * force ssl in varnish + added a bunch of security headers
  * fix bug where add_post was crashing postgresql
  * alot of refactoring for add_post, we are now able to add posts contextually from within its parent post (to create sub threads)
  * tweak UNIQUE constraints so that slugs are bulletproof (guaranteed unique within siblings)
  * woot can surf now to posts and forums with new /t/ scheme, also updated uri generation
  * small refacgtor
  * latest wip, post doc (for sub posts / thread view)
  * bugfix add posts work again, constraint was too anal
  * fix missing methods
  * allow specification of fields for menu query, etc...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * exposes issues converting procs from ls -> js
  * bugfixes
  * check in work in progress, overhauled uri, generate them automatically from slugs recursively..
  * more cleanup
  * merge conflict fix and a lil more
  * made various functions to recursively/automatically generate absolute uris for us (meant to be used after loading fixtures and at insert time)
  * active id for forum urls
  * load fancybox assets
  * fixed main menu active among other ui
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * working again (no 'mo site-id)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added fancybox
  * wip work to allow sub-posts to be added
  * use body text for slug in case of sub-posts
  * allow parent_id to replace title in validations, insert parent_id if they pass it thru
  * lol fixed the bug it was SOO easy and insidious, problem was with get-doc
  * remove debugging
  * generate a unique slug every time a post is made (for forum slugs, the onus is on the administrator)
  * remove cruft
  * remove un-needed second sql lookup
  * fix debug route for doc retrieval
  * works better than b4 but still borked
  * expand loop_prevention constraint to include equality since parent_id should != id ever
  * build_all_docs was incorrectly targeting all forums from all sites and assigning them the wrong site ids, it now is targets the respective site_id
  * fixed forum_doc_by_type_and_slug
  * made it work again, but only really works for site-id 1 for now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * now using async.map instead of for-loop
  * refactored to add site_id key through entire app
  * added forums and posts fixtures for our new sites
  * added davesan to users/aliases and gave him beer.pb.com
  * add helpers as h to repl
  * augment add-dates to included updated and more extensible as we add new date fields, and handle null case
  * testing lighter theme
  * flip backgrounds back
  * fix & simplify setting main menu active
  * hopefully, i fixed the problem in views/posts.jade
  * learning from Paul Graham's mistake ;) - http://www.reddit.com/r/programming/comments/18rluq/paul_graham_creates_a_loop_in_the_database_hacker/c8hf12a
  * wrapped all posts in div.forum; changed (if forum) to (if false) for now; not sure why mutant vs. non-mutant is so different
  * fdm=indent for app/mutants.ls as well
  * very broken, but lets you see a thread on fresh loads // no mutation yet
  * added posts to forum doc when thread is requested
  * fdm=indent works really well for livescript.  just use zO and zC to open and close recursively
  * exported u.sub-posts-tree as a stored proc
  * removed test stored proc
  * misc. layout & style
  * give thread links mutant powers
  * give subforum links mutant goodness, fix bug where title would not be set correctly from locals
  * make subforums use mutant transformations too (why is it that the toplevel menu items don't need the mutant class for surfing)
  * added default delay to scraper
  * bin/scrape-mma --forum N // scrape forums other than forum-id = 1
  * installed commander
  * some markup and style changes for forum list in left nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make full cell clickable on submenu
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * restyled default theme and added /admin mutant stub
  * closes #18 z-index
  * post to active forum id instead of hardcoded one (Thanks mutant.marshal and keith)
  * bugfix
  * taming of the content
  * forums now can swap between recent and active from an url, but not anywhere from ui yet
  * create a new type of forum doc for the two sort types we have so far, recent / active, enable more limiting in sql all over
  * small refactor
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * unbork my route: http://mma.pb.com/debug/docs/homepage_recent/1
  * fix html
  * more map series
  * work in progress on thread handling code
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * cleaned up scraper a tiny bit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * higher-order fun to limit homepage overview
  * added thread list to nav
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * got rid of favicon.ico route, because 404 is working again
  * we have a working 404 page again
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * decided not to use accordion, creating custom slide on hover/click for sub-forums & top-posts in nav
  * it's actually inserting posts; hardcoded to just forum 1 for now
  * post.body should be text (because post bodies can get big)
  * ajax/register -> auth/register
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * a work in progress for scraping mma.tv
  * cssmin only in production
  * + cssmin for our /dynamic css route
  * upgrade jquery ui + custom bundle
  * adds custom css 'classes' to forums expressed in jade layouts
  * forgive me matt, temporary hack to get forums sorted the same as where I scraped them from
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * extra style for new data
  * reduced debounce to 100ms
  * adds forum id to html class and removes duplicate doc
  * sort forums by activeness also on homepagedoc (for homepage_active doc)
  * now building homepage_recent and homepage_active doc for sites
  * oops forgot this part
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * factor out everything to take a 'top-posts' fun
  * data from the wild
  * shorten merge function to 2 LOC from 3
  * used the power of immutability to cure my recursive headache, doc generation is buggy, should now be fixed
  * small refactor plus create our own immutable merge function for use in plv8
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add loc to posts
  * adds maxmind geoip and 3-stage targeting middleware; active on homepage
  * npm install hashish@0.0.4
  * added handy dandy debug route for seeing docs with jsonview in ff (or other pretty json viewing browser plugin), for example: http://mma.pb.com/debug/docs/forum_doc/1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * layout finesse
  * added id to auths table
  * fix bug in postgres recipe
  * fixed nodejs chef recipe, much less code, closes #1
  * chef recipe cleanup
  * handle unknown domains gracefully instead of KABOOM
  * more frontend finesse
  * theory code
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * your passwords
  * frontend fixes, menu animations, etc...
  * bug fixes galore
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * massive commit
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * created second denormalize blob for homepage
  * very rough local auth :: /auth/login and /auth/logout
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix rate limiting
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * create Passport for each domain; available in auth.passports-for-site
  * forgot to update client templates and entry
  * linkify header text for forums on homepage
  * yay add post ui is not broken anymore, also bodyparser moved to beginning of mw to stop hanging the connections
  * add-post fixed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fixed subforums in menus
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * workaround for lame globalness for now
  * use menu object instead of forums object for top menu
  * fix menu in data
  * latest changes
  * fix bug oop
  * use nicer name for procedures
  * watch the procedures too
  * build_all_docs procedure, to be ran after fixtures / data loaded in normalized sql tables
  * page loads but the mutants are funkyzz
  * latest wip data looking better
  * merge / latest wip oops
  * it works
  * adds forum path parts, site to varnish cache key & stubs for forum
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * forum doc + homepage doc now works
  * upgraded livescript
  * subforums + individual forum lookup added
  * merge conflict
  * formatting plus fix bug from doc rename
  * missed a spot: s/get-doc/doc/
  * s/user/usr/
  * verbiage refactor + syntax fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * main menus linked up better and start of subforum menus
  * drop if exist
  * fleshed out sites
  * fleshing out passport setup
  * faster restart
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added passport-twitter
  * added passport-facebook
  * added passport-google
  * vary post users
  * set active menu item on load
  * hook mw.multi-domain into db.find-site-by-domain
  * fixed typo s/Gproc/proc/
  * whitespace
  * pg.procs.find-site-by-domain()
  * mma forum theme, fixtures, etc...
  * + visionmedia's node-migrate
  * building out forum view
  * a couple bug fixes
  * added email to users schema
  * header toggler works again
  * split layout from entry (layout is now reusable) and then some
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * moved post resources there and refactored a bit
  * remove un-needed / placeholder stub validations file
  * more voltdb cleanup and misc cleanup, make procedure names even prettier in node-land
  * nuke data.ls allow multiple json parameters to be defined (positional)
  * default arg for callback
  * automatic json serialization, assume all postgres procs take a json blob for arguments and one json blob for return
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make put-doc more consistent with its rvals
  * added foreign key constraints to protect or dataz + fixtures that've been fixed
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added a find_user stored proc
  * stop using data .. looking to delete data.ls
  * fix add post
  * remove legacy stuff
  * stylistic refactoring, call procs 'db'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix everything i broke
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * + passport-local
  * fix add_post now that i unwrap the json
  * make put consistently return val
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * now that json is assumed, automatically unwrap json
  * various refactoring, remove unused codes, and target only return type json for node land
  * refining ur procedures
  * changed row.updated trigger to be called BEFORE update
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * find_or_create + add-post work
  * added unique on alias.site_id and alias.name
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * improve ui with less data
  * more voltdb cleanup
  * assume ubuntu in nodejs and avoid problematic build-essential
  * drop database should not fail rest of script, sometimes db don't exist
  * add post form works and updates homepage (after refresh) woot
  * fixed upsert and the put-doc bug, arguments was dissapearing lol
  * fixed the upsert
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * gruntwork to compile plv8_modules/*.ls to *.js
  * removed subtransaction; upsert seems to work for both insert and update
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * get-doc shouldn't JSON.parse nulls
  * updated a table's sequence if it has one
  * default task boots pb again
  * volt cleanup
  * Merge branch 'postgres' of github.com:khoerling/powerbulletin into postgres
  * use builtin pooling, init just initializes procs now
  * misc.
  * matt's oneliners for bootstrapping pg rolled into a script
  * use local user on os x; otherwise, postgres
  * Merge branch 'master' of github.com:khoerling/powerbulletin into postgres
  * homepage load works with homepage doc from pgsql generated from add_post procedure !
  * smaller header when expanded
  * Merge branch 'master' of github.com:khoerling/powerbulletin into postgres
  * added onUnload to mutants and using css to manage mutant ui state
  * wrote put_doc2 and get_doc2 in data which use postgres instead
  * wip ported most of homepage building, just needs a lil more tweaking
  * Merge branch 'master' of github.com:khoerling/powerbulletin into postgres
  * add inline shared pure validations + serverside validations for procedures
  * bug fixes, ready for onUnload or some method of cleanup from mutant states
  * mutants switch more fluidly, latest layout, big refactor & cleanup, added left_content
  * more proof of concept stuff, like call procedures in our lib code
  * refactoring so sql doesn't make eyes bleed
  * proof of concept get_user with arguments
  * updated rest of fixtures for postgres schema
  * fix aliases fixtures, and users fixtures
  * wip converting fixtures etc to postgres, don't wanna break stuff in master
  * automatically populate postgres.procs from functions residing in postgres database 'pb' and in the generation, provide a function which automatically handles varargs
  * some stylistic changes to procedure, add postgres init to repl, without bugging ppl who don't have postgres running yet
  * tweak chef recipe to use our branch of plv8js instead
  * check in plls procedures modules folder which will be symlinked in production for reusable procedure code
  * add plv8 to chef recipe
  * updated schema to be postgresql friendly
  * inherit commandline args for bin/psql
  * hello postgres, goodbye voltdb (chef recipe for now, don't wanna break anything)
  * Revert "cleanup" welcome back, postgres
  * + build_form
  * non-working schema tweaks
  * adds forumdoc & slug to voltdb
  * latest changes
  * finally we can generate something that the view can consume
  * indentation
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay homepage doc getting alot closer wip
  * + history.js
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * application/json
  * manually clone locals
  * work in progress for homepage building
  * added a secret in cvars
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip of toplevel forums and posts to build homepage doc
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest style & jade for clean /forums
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * added express.cookieSession() middleware
  * added helpers.add_dates to turn created fields into Date objects
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in WIP for building homepage doc from actual sql tables
  * installed passport
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * npm install contextify via chef
  * point contextify with symlink to global install (chef recipe will take care of it)
  * start sequence for posts at 100 so we don't stomp on fixtures
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more fixtures, add forum_id to posts
  * removed contextify from node_modules; going global for compiled stuff
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * addd some utility functions, wip for build-all procedure, start of fixtures
  * /forum-(id) loading again
  * fix jsdom??
  * move stubbing into stored procedures
  * fix determinism in top posts fetching
  * small correction
  * check in comments for clojure n00bs
  * reduce data size
  * t pushMerge branch 'master' of github.com:khoerling/powerbulletin
  * bugfix to initStubs
  * /forum mutates and that's about it
  * forum wip 2
  * config tweaks to hopefully help responsiveness on nodejs client side
  * ui uses new clojure add-post2
  * yay add-post can serialize nice looking json that we can consume in nodejs
  * clojure procedure overhaul, we got nice abstractions now\ add-post2 now gens its own seq
  * decoupled homepage doc from a particulare procedure with build-homepage
  * fix broken defproc macro, we couldn't change namespaces so full qualification is needed
  * stop using broken procedure for health check lol
  * snapshot every 10s (to make dev easier for now) and the create command prints to stdout instead of to voltdb.log
  * separate launch and create tasks for voltdb, this way we don't stomp data accidentally
  * npm install clientjade locally, and update gruntfile accordingly
  * left/right forum mutant wip
  * sped up waypoints, added some css & data
  * sticky waypoints working better with awesome scroll-to
  * small tweaks that go far
  * + waypoints.min
  * ui fixes, added more sort/filter kinds
  * sticky forum headers
  * adds neat sorting ui and the triangles attack!
  * added smooth & smarter scroll-to functions
  * + blob.png
  * ability to add a custom css class to theme each forum
  * grunt, mutant & layout updates to work better with clientjade
  * an inverted theme and ui bits to make posting more obvious
  * split up jade templates, re-enabled mutant and loading homepage now
  * misc. style++
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * back to res.render
  * figured out how to make useful functions available to our clojure-based procs
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest compiled jade & grunt task
  * a little more refactoring ...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ok added updated/created to docs, more tweaks to first awesome clojure procedure (add-post)
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add contextify to make jsdom happy
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * clientjade + grunt task
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * wip on add-post
  * able to generate functions for whatever it's worth in tmpl.ls
  * jade template compiler
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * made defproc more DSL-like
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remarked out templates
  * mutant working, though not rendering jade
  * cleanup
  * add-post2 works
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in wip add_post2
  * surfable routes part of mutant
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * fix health check
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest tweaks to make voltdb more resilient when connection is lost (in node land)
  * + jsdom & lowdash, process cache helper and mutant basics
  * check in WIP of voltdb timeouts + health checks
  * merge conflict fixerizer
  * enable snapshots, and loading of snapshots on startup of voltdb
  * grunt boots volt & zsh fix
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * append to voltdb.log instead
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * more responsive add comment and a couple ff fixes
  * when you launch voltdb, try to load last snapshot
  * launch pb after voltdb is up and running
  * fixup hostname
  * snapshot every 30s
  * turn on auto snapshots
  * extracted defproc into its own file so other clojure voltdb procs can use it
  * recompile voltdb procs and start up voltdb through grunt
  * installed shell.js for convenience
  * added inline commenting among many other enhancements
  * better ui controls, faster background switch & working on user profile
  * fix bug in add-post that refactor broke
  * api cleanup, move stuff into data, move old api stuff out of voltdb
  * created a more dsl-like way to grab statements
  * proof of concept requiring of a tertiary module for the browserify bundle
  * browserify baby
  * and were back houston
  * whoops fixed bug where minified version wasnt used
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * switched to using component to compile our entrypoint, use lib/pb-entry/index.ls instead of app/layout.ls, also hooked up minification to new entrypoint
  * less initial chrome & extra sharpness to logo+forum separator
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * inverted post/subpost translucency
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * birth of 'defproc' macro for defining volt procedures
  * posts/sub posts
  * quicker initial build-in & waypoints update on resize
  * quicker initial load
  * slick background fx when scrolling through forums
  * top bar & search ui more integrated
  * menu mostly dynamic (need sub-forums to exist first) and layout+++
  * sharpness & the top drawer
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest style
  * added real ids to data doc & updated jade
  * fixes for select_user procedure and also forgot to checkout clojure branch for voltdb provisioning
  * add recipe to install custom voltdb for clojure instead of vanilla 3.0
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * yay partitioned procedures in voltdb + clojure
  * thinking about seo...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * basic waypoints among many other ui improvements
  * more randomization in test data
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * make order determinate
  * readying for parallax categories & waypoints
  * fixes and speed/ui improvements
  * wip with clojure bizness
  * add a little more friendliness to the voltdb api
  * some refactoring, need 2gb ram for compiling voltdb, classpath more manageable now
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * compile pb entry from component system, will integrate with grunt later and have grunt do the jade/stylus/ls stuff + uglify the final entry file
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * refactored to work with latest voltdb schema
  * remove date header
  * check in WIP for components
  * adds volt+d for data to repl
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * bin/repl with preloaded libraries
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * add component to npm global install
  * added lib/mutant and removted .git dir first
  * Revert "added mutant locally"
  * added mutant locally
  * change json serialization so it actually updates the front page
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove comments, unified concept of posts
  * removed symlink
  * working on menus...
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * back to single-width columns and misc.
  * fix: spacing
  * - bootstrap
  * jQuery is back (no more zepto)
  * i know its ugly but i want this placeholder somewhere =D
  * voltdb 3.0 tweaks, come back of clojure yay
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * npm install git://github.com/VoltDB/voltdb-client-nodejs.git
  * commit bugfix so it will compile for now
  * now using zepto!
  * resolve merge conflict
  * update to voltdb 3.0 (type vagrant provision to get latest voltdb first)
  * removed makeshift doc (for where voltdb isn't yet setup)
  * added 2 sizes of columns, improved masonry/pinterest style view and then some
  * massive ui bundle brosivs!
  * added docs and a caching function for hash index later..
  * change name to something more fun -- front page loads using doc from voltdb
  * homepage populated from docs now, use data.init-stubs()
  * give voltdb 256m for now
  * return all responses for AddPost
  * AddPost needs to be a MP procedure since the parameter is not hashed the same for both docs and posts
  * can now submit post to voltdb
  * fussing with ui/x, needs rich media in the content and to figure out how to stylishly and intuitively render threads+posts
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * latest ui concepts
  * everything is now single partition
  * everything is single partition now
  * sequences have arrived. we can now add multiple posts that generate their own unique ids in voltdb
  * screw classes, its all about ad-hoc data structures baby
  * oh yeah, my first procedure to populate both a json doc in the docs table and a post in the posts table, all with one procedure in voltdb land, all atomically
  * wip for json in voltdb
  * offline development (NODE_ENV=development) includes more js+css resources pulled from public/local
  * yay my AddPost procedure works
  * stylistic tweak
  * work in progress for a stored procedure which stores also a doc with json
  * add parent_id to comments
  * readability / consistency improvements
  * w00t my first worthless util function in clojure can be used on VoltTable[]
  * push up working voltdb procedure code, can still use clojure for meat but have to define VoltProcedure java files
  * chef recipe for postgres 9.2, app/postgres.ls shim for queries
  * install pg@0.11.1
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * check in work-in-progress for voltdb procedures, still getting NullPointerException, but really close to working...
  * - vdb (should use data.ls instead :)
  * more ui mocking
  * + added js/local and auto-switcher for offline dev when NODE_ENV is 'production'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * ui wip and then some
  * add shortcut to clojure repl, aot compile for voltdb will be different script
  * bugfix
  * clojure recipe
  * we now have reciprocal actions, put-misc-doc and get-misc-doc
  * create a convenience function for inserting a misc doc
  * remove default value
  * removed dead code
  * added some express validor stuff, will use this to create a registration process
  * install express-validator@0.3.1
  * placeholder route for registration
  * remove dead / not working code
  * factor our base_js_urls into new common.json config in config folder which is for configs which make sense in all environments
  * got schemaless with js urls
  * add script to kill everything in dev when grunt starts my stuff up too many times when code is broken, also, use cdn for headjs
  * buncha caching tweaks, treat varnish and cdns the same pretty much, remove cruft we didn't need, and blow the cache on js and css after each git deploy
  * removed manual js url since we should be using cdn urls for static resources, and since now our static server is tweaked to have a longer max-age now
  * simplify environment config loading, use builtin nodejs json loading
  * latest stuff, abstract locals into external datasource for homepage, keeping it high level for now
  * Revert "cleanup"
  * cleanup
  * Grunt, too
  * moved configs to config/ and fixed production error handler
  * initial skeleton for clientside of voltdb
  * npm install git://github.com/VoltDB/voltdb-client-nodejs.git
  * install voltdb tools also (which allows easy commandline save and restore of snapshots)
  * forward port 8080 for voltdb
  * add launch-voltdb script
  * prefer shorter 'type' to 'doctype'
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * compile-voltdb script added, and initial placeholder schema based on my messing around
  * varnish tweaks, make dev mode not cache at all (1s)
  * no longer conditionally enable caching_strategies, just set the ttl super short in varnish
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * remove graffiti and see stager automatically put it out there
  * syntax wrong
  * graffiti added to test staging process w/ varnish
  * latest changes
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * test change to see if stager works
  * more tweaks so processes are killed properly
  * latest continuous indexer changes
  * die kitty, die, no more testing stuff
  * test
  * testing something else
  * tester
  * one last test
  * one last test
  * another test
  * test noise for stager
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * testing to see if staging is updated automagically
  * be more talky when you update staging
  * first whack at a pretty ghetto continuous stager
  * Update README.md
  * update readme about firewall tricks in mac os x
  * remove unecessary compiling of main.ls, remove config.json from version control and ignore it, that should be copied after cloning into place depending on env
  * enable max-age in the express.static middleware, so we get nice cacheability
  * update main.js
  * varnish file tweaks to hide some headers and allow webapp to have explicit control over varnish ttl again
  * setup varnish with basic config to start which has gzip enabled
  * use pbstage.com for staging
  * need build-essential for gem installation
  * forgot to skip the interactive part
  * added script to provision servers apart from varnish
  * Merge branch 'master' of github.com:khoerling/powerbulletin
  * avoid sadness
  * grunt using config.json & moved pid to /tmp
  * buncha etag tweaks
  * added details to readme
  * yay grunt works on vagrant and global npm install too
  * check in recipes for nodejs, stunnel, varnish, voltdb, vagrant up works with ubuntu 1204, livescript and grunt preinstalled globally post npm and nodejs
  * initial vagrant stuff, one can bootstrap an omnios box but the recipes dont do anything yet, apt-get u was my friend, now i have to do more work ; )
  * see if i got access to git repo
  * working on ui frame
  * "launch" grunt task fixed and server now restarts automatically!
  * refactored jade views into blocks
  * refactored common into helpers and added folds+comments
  * rendering test data and added common functions
  * working on posts...
  * using centered header layout & added scroll-to-top
  * amazingly responsive start on the skeleton layout (borrows from digg, reddit & express), added a dynamic route for ls -> js, separated stylus theme which'll get replaced by site-specific ones later, and many other goodies
  * now serving a fresh cup of static cache-domain content
  * cache domains, responsive 2-column layout (needs spring for right-nav), stylus+fluidity+layout theme, and so much more!
  * adds concept of handlers & express-resources, and some middleware goodness
  * initial route in-place: http://www.localhost:3000/hello & basic middleware
  * added ability to host multiple domains per express instance, fixes & working on "grunt launch"
  * + fluidity
  * the rest...
  * ./bin/PowerBulletin launches!
  * initial grunt'work & skeleton
  * Initial commit
