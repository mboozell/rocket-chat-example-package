FinLabs.WiseGuy.tabBarItem =
    i18nTitle: "finlabs-wiseguy:WiseGuy_Alerts"
    icon: "icon-bell"
    id: "wiseguy"
    template: "wiseGuyAlerts"
    order: 10

Meteor.startup ->
    RocketChat.callbacks.add 'enter-room', ->
        if RocketChat.authz.hasAtLeastOnePermission 'view-wiseguy-alerts'
          RocketChat.TabBar.addButton FinLabs.WiseGuy.tabBarItem
          , RocketChat.callbacks.priority.MEDIUM, 'enter-room-tabbar-wiseguy'
