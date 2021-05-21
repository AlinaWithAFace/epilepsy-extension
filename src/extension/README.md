# Photosensitivity Extension Client

This is directory houses code for the chrome extension.

# Project Structure

The majority of the code is in the `src/` directory.

The `.elm` source files are compiled to a Javascript file `target.js`
which is then used in the `index.js` and `index.html` files.

# Installation/Testing

To test out the extension in Google Chrome, follow these instructions:

1.  In Google Chrome, go to the address `chrome://extensions`.
2.  On this page, enable developer mode by clicking the toggle-able
    button in the top-right corner
3.  Click "Load Unpacked"
4.  Open this directory when prompted
5.  You should now be able to see the Episense extension. You can pin it
    to the title-bar if you want.
