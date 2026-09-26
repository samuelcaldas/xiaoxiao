byteloaded = _root.getBytesLoaded();
bytetotal = _root.getBytesTotal();
loaded = int(byteloaded / bytetotal * 100);
t = getTimer();
percent = loaded + "%  ( " + int(byteloaded / 1000) + " K / " + int(bytetotal / 1000) + " K )";
percent = percent + "\r{invalid_utf8=207}{invalid_utf8=194}{invalid_utf8=212}{invalid_utf8=216}{invalid_utf8=203}{invalid_utf8=217}{invalid_utf8=182}ȣ{invalid_utf8=186}" + int(byteloaded / t * 100) / 100 + " K/s";
load_bar.gotoAndStop(loaded);
