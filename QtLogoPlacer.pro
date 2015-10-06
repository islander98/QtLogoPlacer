TEMPLATE = app

TARGET = LogoPlacer

QT += qml quick widgets

SOURCES += main.cpp

RESOURCES += qml.qrc

RC_ICONS = LogoPlacer.ico

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    signallistener.hpp

DISTFILES +=
