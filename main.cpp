// Copyright 2015 Piotr Trojanowski

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.

// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

#include <Qtcore>
#include <QApplication>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QtDebug>
#include <QMetaObject>
#include <QQuickWindow>
#include <QImage>
#include <QVariant>
#include <QQuickItem>
#include <QQmlProperty>
#include <QPoint>

#include "signallistener.hpp"

void SignalListener::exportImage(const QVariant &_window)
{
    qDebug() << "Handler called";

    QQuickWindow *window = qobject_cast<QQuickWindow*>(_window.value<QObject*>());
    if (!window)
    {
        qWarning() << "Could not obtain main window object";
        return;
    }

    QObject *screenshotArea = window->findChild<QObject*>("screenshotArea");
    if (!screenshotArea)
    {
        qWarning() << "Could not obtain screenshot area object";
        return;
    }

    QQuickItem *screenshotAreaItem = window->findChild<QQuickItem*>("screenshotArea");

    int x = QQmlProperty::read(screenshotArea, "x").toInt();
    int y = QQmlProperty::read(screenshotArea, "y").toInt();
    int width = QQmlProperty::read(screenshotArea, "width").toInt();
    int height = QQmlProperty::read(screenshotArea, "height").toInt();
    QPointF mappedCoords = screenshotAreaItem->mapToScene(QPointF(x, y));

    qDebug() << "Screenshot area: x=" << mappedCoords.x() << " y=" << mappedCoords.y() << " w=" << width << " h=" << height;

    QImage fullScreenshot = window->grabWindow();
    QImage trimmedScreenshot = fullScreenshot.copy(mappedCoords.x(), mappedCoords.y(), width, height);

    if (!trimmedScreenshot.save("Image.png"))
    {
        qWarning() << "Could not save the screenshot image";
    }
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlEngine engine;

    QQmlComponent component(&engine, QUrl(QStringLiteral("qrc:/main.qml")));
    QObject *object = component.create();

    SignalListener s;
    QObject::connect(object, SIGNAL(exportImage(QVariant)),
                         &s, SLOT(exportImage(QVariant)));
    QObject::connect(&engine, SIGNAL(quit()), &app, SLOT(quit()));

    return app.exec();
}
