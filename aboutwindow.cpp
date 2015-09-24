#include <QtCore>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQuickWindow>

AboutWindow::AboutWindow(QQmlEngine* engine, QObject* parent)
    : fComponent(NULL),
      fRootObject(NULL),
      fIsOpen(false)
{
    fComponent = new QQmlComponent(engine, QUrl(QStringLiteral("qrc:/" ABOUTWINDOW_QML_FILENAME)), parent);
    if (fComponent)
    {
        fRootObject = fComponent->create();

        if (fRootObject)
        {
            qobject_cast<QQuickWindow*>(fRootObject)->show();
            fIsOpen = true;
        }
        else
        {
            qWarning() << fComponent->errorString();
            delete fComponent;
        }
    }
    else
    {
        qWarning() << fComponent->errorString();
    }
}

AboutWindow::~AboutWindow()
{
    if (fIsOpen)
    {
        delete fRootObject;
        delete fComponent;
    }
}
