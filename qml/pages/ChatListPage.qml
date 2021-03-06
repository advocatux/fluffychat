import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent
    id: chatListPage


    // This is the most importent function of this page! It updates all rooms, based
    // on the informations in the sqlite database!
    function updateList () {

        // First step is obviously clearing the column
        chatListColumn.children = ""

        // On the top are the rooms, which the user is invited to
        storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, events.id AS eventsid, events.origin_server_ts, events.content_body, events.sender, events.content_json, events.type, members.displayname FROM Rooms rooms LEFT JOIN Roomevents events JOIN Roommembers members " +
        " WHERE rooms.membership!='leave' " +
        " AND (rooms.id=events.roomsid OR rooms.membership='invite') " +
        " AND (members.roomsid=events.roomsid OR rooms.membership='invite') " +
        " AND (members.state_key=events.sender OR rooms.membership='invite') " +
        " GROUP BY rooms.id " +
        " ORDER BY events.origin_server_ts DESC "
        , function(res) {
            // We now write the rooms in the column
            for ( var i = 0; i < res.rows.length; i++ ) {
                var room = res.rows.item(i)
                // We request the room name, before we continue
                var newChatListItem = Qt.createComponent("../components/ChatListItem.qml")
                newChatListItem.createObject(chatListColumn,{ "room": room,})
            }
        })

    }


    Component.onCompleted: updateList ()

    Connections {
        target: events
        onChatListUpdated: updateList ()
    }


    header: FcPageHeader {
        trailingActionBar {
            actions: [
            Action {
                iconName: "settings"
                onTriggered: mainStack.push(Qt.resolvedUrl("./MainSettingsPage.qml"))
            },
            Action {
                iconName: "add"
                onTriggered: mainStack.push(Qt.resolvedUrl("./AddChatPage.qml"))
            }
            ]
        }
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            id: chatListColumn
            width: root.width
        }
    }

    Label {
        text: i18n.tr('Swipe from the bottom to start a new chat')
        anchors.centerIn: parent
        visible: chatListColumn.children.length === 0
    }

    // ============================== BOTTOM EDGE ==============================
    BottomEdge {
        id: bottomEdge
        height: parent.height
        contentComponent: Rectangle {
            width: root.width
            height: root.height
            color: "white"
            AddChatPage { }
        }
    }

}
