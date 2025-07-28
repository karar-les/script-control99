--[[
🔥 سكريبت محمد الشمري 🔥
--]]

-- متغيرات النظام
local savedValues = {}
local startTime = os.time()
local PASSWORD = "TUX3T"
local EXPIRE_DATE = os.time({year = 2025, month = 12, day = 31})
local fancyMessages = {"حمودي"}
local SCRIPT_VERSION = "1.0.1"
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/karar-les/script-control9/main/script.lua"
local GITHUB_VERSION_URL = "https://raw.githubusercontent.com/karar-les/script-control9/main/version.txt"

-- وظيفة تنزيل الملف من GitHub
function downloadFromGitHub(url)
    local success, result = pcall(gg.makeRequest, url)
    if success and result and result.content then
        return result.content
    end
    return nil
end

-- وظيفة التحقق من التحديثات
function checkForUpdates()
    gg.toast("🔍 جاري التحقق من التحديثات...")
    
    -- التحقق من الإصدار أولاً
    local onlineVersion = downloadFromGitHub(GITHUB_VERSION_URL)
    if not onlineVersion then
        gg.toast("⚠️ تعذر التحقق من التحديثات")
        return false
    end
    
    -- مقارنة الإصدارات
    if onlineVersion ~= SCRIPT_VERSION then
        local choice = gg.alert(
            "يتوفر تحديث جديد ("..onlineVersion..")!\n\n"..
            "الإصدار الحالي: "..SCRIPT_VERSION.."\n\n"..
            "هل تريد التحديث الآن؟",
            "نعم", "لا")
        
        if choice == 1 then
            gg.toast("⏳ جاري تنزيل التحديث...")
            local newScript = downloadFromGitHub(GITHUB_RAW_URL)
            if newScript then
                -- حفظ السكربت الجديد
                local file = io.open(debug.getinfo(1).source:sub(2), "w")
                if file then
                    file:write(newScript)
                    file:close()
                    gg.alert("✅ تم التحديث بنجاح!\nسيتم إعادة تشغيل السكربت.")
                    os.exit()
                else
                    gg.alert("❌ فشل حفظ الملف المحدث")
                end
            else
                gg.alert("❌ فشل تنزيل التحديث")
            end
        end
    else
        gg.toast("✔️ أنت تستخدم أحدث إصدار")
    end
end

-- وظيفة التحقق من الصلاحية عبر الإنترنت (معدلة)
function checkOnlineExpiry()
    gg.toast("🔍 جاري التحقق من الصلاحية...")
    local expiryContent = downloadFromGitHub("https://raw.githubusercontent.com/karar-les/script-control9/main/expiry.txt")
    
    if not expiryContent then
        gg.alert("⚠️ تعذر التحقق من الصلاحية عبر الإنترنت\nسيتم استخدام التاريخ المحلي")
        return false
    end
    
    local onlineExpiry = tonumber(expiryContent:match("%d+"))
    if not onlineExpiry then return false end
    
    local now = os.time()
    if now > onlineExpiry then
        gg.alert([[
تم انتهاء صلاحيه السكربت عبر الإنترنت
للاشتراك تلكرام @TUX3T
        ]])
        os.exit()
    end
    
    -- تحديث تاريخ الانتهاء إذا كان التاريخ عبر الإنترنت أقصر
    if onlineExpiry < EXPIRE_DATE then
        EXPIRE_DATE = onlineExpiry
        if (EXPIRE_DATE - now) < 86400 then
            gg.alert("تنتهي صلاحيه السكربت خلال 24 ساعه ⏲︎")
        end
    end
    
    return true
end

-- وظيفة التحقق من الباسورد والصلاحية (معدلة)
function checkAuth()
    gg.alert([[
 ☛ محمد الشمري ☚
    ]])
    
    -- التحقق من التحديثات عند التشغيل
    checkForUpdates()
    
    gg.alert("Telegram - @TUX3T ®︎\nباسورد !")
    local input = gg.prompt({"®︎ أدخل باسورد :"}, nil, {"text"})
    
    if not input or input[1] ~= PASSWORD then
        gg.alert("خطا خطا ✖︎ ")
        os.exit()
    end

    -- التحقق من الصلاحية
    if not checkOnlineExpiry() then
        local now = os.time()
        if now > EXPIRE_DATE then
            gg.alert([[
تم انتهاء صلاحيه السكربت للاشتراك تلكرام @TUX3T
            ]])
            os.exit()
        elseif (EXPIRE_DATE - now) < 86400 then
            gg.alert("تنتهي صلاحيه السكربت خلال 24 ساعه ⏲︎")
        end
    end

    -- رسائل ترحيبية
    gg.alert(" اهلا وسهلا بك ☪︎")
    gg.alert("استمتع بوقتك ⏲︎")
end

-- باقي الوظائف تبقى كما هي (iPadView, activatePossession, cancelMatch, resetAll, speedMenu, packsMenu, mainMenu)

-- إضافة خيار التحديث في القائمة الرئيسية
function mainMenu()
    while true do
        if gg.isVisible(true) then
            gg.setVisible(false)
            checkRuntime()
            
            local menu = gg.choice({
                "☰ قائمة المباراة",
                "☰ قائمة السرعة",
                "☰ قائمة البكجات",
                "🔄 إعادة ضبط القيم",
                "🔄 التحقق من التحديثات",
                "✖︎ خروج"
            }, nil, "احذر التقليد تلكرام @TUX3T")
            
            if menu == 1 then
                -- قائمة المباراة
                local matchChoice = gg.choice({
                    "®︎ تفعيل الاستحواذ",
                    "®︎ تفعيل منضور الايباد ︎",
                    "®︎ إلغاء المباراة اونلاين",
                    "🔙 رجوع"
                }, nil, "☰ قائمة المباراة")
                
                if matchChoice == 1 then
                    activatePossession()
                elseif matchChoice == 2 then
                    iPadView()
                elseif matchChoice == 3 then
                    cancelMatch()
                end
                
            elseif menu == 2 then
                speedMenu()
                
            elseif menu == 3 then
                packsMenu()
                
            elseif menu == 4 then
                resetAll()
                
            elseif menu == 5 then
                checkForUpdates()
                
            elseif menu == 6 then
                gg.alert("اهلا وسهلا ✔︎")
                os.exit()
            end
        end
        gg.sleep(300)
    end
end

-- بداية التشغيل
checkAuth()
mainMenu()
