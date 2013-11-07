@can-list-site-users = (user, site-id, cb) ->
  if user.rights.super
    cb null true
  else
    cb null false

@can-edit-user = (user, target-user-id, cb) ->
  if user.rights.super or (user.id is target-user-id)
    cb null true
  else
    cb null false

@can-edit-post = (user, post-id, cb) ->
  if user.rights.super
    cb null true
  else
    cb null false

@can-edit-user-email = (user, cb) ->
  cb null false

@can-change-sys-privileges = (user, cb) ->
  cb null false

# sys admins can ALWAYS change site privileges
# site owner can ALWAYS change site privileges on THEIR SITE (based on user_id column of sites)
# site admins can change site privileges on everyone on THEIR SITE except the site owner
#
# THIS IS THE ONLY PLACE WE SHOULD CHECK FOR SITE OWNER, user site admin everwhere else
# site owners should not be able to unset their site admin status
@can-change-site-privileges = (user, site-id, target-user-id, cb) ->
  cb null false

# site admins can ALWAYS access forums
#
@can-access-forum = (user, forum-id, cb) ->
  # site admins can always access a forum
  # if forum is marked private then check the users forum permissions
  cb null false

# sys admins can ALWAYS access everything
for k, v of @
  do ~>
    orig-fn = v
    @[k] = (user, ...args, cb) ~>
      if not user
        return cb null, false
      else if user.sys_rights.super
        return cb null, true
      else
        orig-fn.apply @, arguments

