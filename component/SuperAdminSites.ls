define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

module.exports =
  class SuperAdminSites extends PBComponent
    title: 'Edit Sites'
