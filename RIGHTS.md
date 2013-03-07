# this is pseudocode for all the stuff that can be in the rights json obj in the users table
    rights =
      site-admin-for:{32:1,99:1} # usage: site-admin-for[site-id]
      site-mod-for:{33:1,44:1,55:1} # usage: site-mod-for[site-id]
      forum-mod-for:{323:1,456:1,2233:1} # usage: forum-mod-for[forum-id]
      is-super:1 # catch-all for everything that we wanna do as super users but don't want general public to do, also gives above priveleges
