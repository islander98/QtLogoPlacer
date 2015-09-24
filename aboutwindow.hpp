#ifndef ABOUTWINDOW_HPP
#define ABOUTWINDOW_HPP

#include <QtCore>
#include <QQmlEngine>
#include <QQmlComponent>

#define ABOUTWINDOW_QML_FILENAME "about.qml"

class AboutWindow
{
public:
    /**
     * Create and show the new 'About' window
     *
     * When window is closed its resources are freed hovewer the object
     * is not destroyed.
     */
    AboutWindow(QQmlEngine *engine, QObject *parent);

    /**
     * Closes the window and frees resources.
     */
    ~AboutWindow();

    /**
     * Check if window is currently open.
     *
     * If the function returns false, the object can be destroyed.
     * @return true if window is open, false otherwise
     */
    bool isOpen();

private:

    // Forbidden copy constructor and operator =
    AboutWindow(const AboutWindow&);
    AboutWindow operator=(const AboutWindow&);

    QQmlComponent *fComponent;
    QObject *fRootObject;
    bool fIsOpen;

};

#endif // ABOUTWINDOW_HPP

