//
//  frida/tw_research.js
//  Скрипт для ПОДТВЕРЖДЕНИЯ IM-классов TikTok на устройстве (джейл/фрида не нужна
//  для sideload-варианта — можно запустить и через runtime логи мода).
//
//  Как пользоваться (с джейлом/frida):
//    frida -U -n TikTok -l tw_research.js
//  Затем в приложении: открыть Inbox, отправить стикер в любой чат.
//  Скрипт распечатает реальные классы/селекторы — впиши их в TWSeriesHeaders.h
//  и TWSeriesManager.m (массивы candidates в файле уже содержат заготовки).
//
//  Без frida: мод сам логирует найденное через TWSeriesManager logStreakDiagnostics
//  (см. Settings -> Auto Streak -> "Диагностика") в Console.app.
//

// 1. Перечислить все классы с IM/Conversation/Sticker/Emoticon/Streak в имени
ObjC.enumerateLoadedClasses({
  onMatch: function (name) {
    if (/IM|Conversation|Sticker|Emoticon|Streak/i.test(name)) {
      console.log("[class] " + name);
    }
  },
  onComplete: function () { console.log("[done] class scan"); }
});

// 2. Спай на отправку стикера: перехватить все sendMessage*-методы у IM-классов
["AWEIMMessageSendService", "IMKitSendMessage", "AWEIMSendService",
 "AWEIMMessageDataController", "AWEIMService", "AWEIMEngine"].forEach(function (cn) {
  var cls = ObjC.classes[cn];
  if (!cls) return;
  var methods = cls.$ownMethods;
  methods.forEach(function (m) {
    if (/send|Send|sticker|Sticker|emoticon|Emoticon/i.test(m)) {
      try {
        Interceptor.attach(cls[m].implementation, {
          onEnter: function (args) {
            console.log("[send] " + cn + " -> " + m);
            for (var i = 2; i < 6; i++) {
              try {
                var a = new ObjC.Object(args[i]);
                console.log("    arg" + (i-2) + ": " + a.toString().substring(0, 200));
              } catch (e) {}
            }
            console.log("    backtrace:\n" + Thread.backtrace(this.context, Backtracer.ACCURATE)
              .map(DebugSymbol.fromAddress).join("\n"));
          }
        });
      } catch (e) { console.log("[skip] " + cn + m + ": " + e); }
    }
  });
});

// 3. Найти streak-поле у модели беседы: мониторим KVC на любой объект с "streak" в описании
Interceptor.attach(ObjC.classes.NSObject.instances.respondsToSelector.implementation, {
  onEnter: function (args) {
    try {
      var sel = ObjC.selectorAsString(args[2]);
      if (/streak|flame|fire/i.test(sel)) {
        var obj = new ObjC.Object(args[0]);
        console.log("[streak?] " + obj.$className + " responds to " + sel);
      }
    } catch (e) {}
  }
});

console.log("[tw_research] hooks installed — открой Inbox и отправь стикер");
