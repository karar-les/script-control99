--[[
🔥 سكريبت محمد الشمري 🔥
--]]

-- متغيرات النظام
local savedValues = {}
local startTime = os.time()
local PASSWORD = "TUX3T"
local EXPIRE_DATE = os.time({year = 2025, month = 12, day = 31})
local fancyMessages = {"محمد الشمري يرحب بكم"}
local SCRIPT_VERSION = "1.0.0"
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/karar-les/script-control9/main/script.lua"
local GITHUB_VERSION_URL = "https://raw.githubusercontent.com/karar-les/script-control99/refs/heads/main/version.txt"
local DEBUG_MODE = true -- ضعها false لتعطيل وضع التصحيح

-- وظيفة تنزيل الملف من GitHub
function downloadFromGitHub(url)
    local success, result = pcall(gg.makeRequest, url)
    if success and result and result.content then
        if DEBUG_MODE then
            print("تم تنزيل المحتوى بنجاح من:", url)
            print("الحجم:", #result.content)
        end
        return result.content
    else
        if DEBUG_MODE then
            print("فشل في التنزيل من:", url)
            print("الخطأ:", result)
        end
    end
    return nil
end

-- وظيفة لتنظيف نص الإصدار
function cleanVersion(versionText)
    if not versionText then return nil end
    -- إزالة المسافات والأسطر الجديدة والفراغات
    local cleaned = versionText:gsub("%s+", ""):gsub("\n", ""):gsub("\r", "")
    -- استخراج نمط الإصدار (x.x.x أو x.x)
    local version = cleaned:match("(%d+%.%d+%.%d+)") or cleaned:match("(%d+%.%d+)") or cleaned:match("(%S+)")
    return version
end

-- وظيفة التحقق من التحديثات المعدلة
function checkForUpdates()
    gg.toast("🔍 جاري التحقق من التحديثات...")
    
    -- جلب محتوى ملف الإصدار من GitHub
    local onlineVersionContent = downloadFromGitHub(GITHUB_VERSION_URL)
    if not onlineVersionContent then
        gg.toast("⚠️ تعذر التحقق من التحديثات")
        return false
    end
    
    -- تنظيف نصوص الإصدارات
    local onlineVersion = cleanVersion(onlineVersionContent)
    local currentVersion = cleanVersion(SCRIPT_VERSION)
    
    if DEBUG_MODE then
        print("====== معلومات التصحيح ======")
        print("المحتوى الخام:", onlineVersionContent)
        print("الإصدار الموجود:", currentVersion)
        print("الإصدار على الإنترنت:", onlineVersion)
    end
    
    if not onlineVersion or not currentVersion then
        gg.toast("⚠️ تنسيق الإصدار غير صحيح")
        return false
    end
    
    -- مقارنة الإصدارات
    if onlineVersion ~= currentVersion then
        local choice = gg.alert(
            "يتوفر تحديث جديد ("..onlineVersion..")!\n\n"..
            "الإصدار الحالي: "..currentVersion.."\n\n"..
            "هل تريد التحديث الآن؟",
            "نعم", "لا")
        
        if choice == 1 then
            gg.toast("⏳ جاري تنزيل التحديث...")
            local newScript = downloadFromGitHub(GITHUB_RAW_URL)
            if newScript then
                -- الحصول على مسار الملف الحالي
                local filePath = debug.getinfo(1).source:sub(2)
                if DEBUG_MODE then
                    print("حفظ الملف المحدث في:", filePath)
                end
                
                -- إنشاء نسخة احتياطية
                local backupPath = filePath..".bak"
                os.rename(filePath, backupPath)
                
                -- محاولة حفظ الملف الجديد
                local file, err = io.open(filePath, "w")
                if file then
                    file:write(newScript)
                    file:close()
                    gg.alert("✅ تم التحديث بنجاح!\nتم إنشاء نسخة احتياطية في:\n"..backupPath.."\n\nسيتم إعادة تشغيل السكربت.")
                    os.exit()
                else
                    gg.alert("❌ فشل حفظ الملف المحدث:\n"..tostring(err).."\n\nتم استعادة النسخة الاحتياطية.")
                    os.rename(backupPath, filePath)
                end
            else
                gg.alert("❌ فشل تنزيل التحديث")
            end
        end
    else
        gg.toast("✔️ أنت تستخدم أحدث إصدار ("..currentVersion..")")
    end
    return true
end

-- وظيفة التحقق من الصلاحية عبر الإنترنت
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

-- وظيفة التحقق من الباسورد والصلاحية
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

-- وظيفة التحقق من وقت التشغيل
function checkRuntime()
    local currentTime = os.time()
    if (currentTime - startTime) > 7200 then
        gg.alert([[
تم تفعيل السكربت لمده زمنيه قصيره ✔︎
        ]])
        startTime = os.time()
    end
end

-- تفعيل منظر iPad
function iPadView()
    gg.setRanges(gg.REGION_C_DATA)
    gg.searchNumber("0.3~03.99", gg.TYPE_DOUBLE)
    gg.searchNumber("0.3~03.99", gg.TYPE_DOUBLE)
    gg.refineNumber("0.3~03.99", gg.TYPE_DOUBLE)
    local revert = gg.getResults(10)

    if #revert == 0 then
        gg.alert("هناك خطا ما ✖︎")
        return
    end

    gg.editAll("2", gg.TYPE_DOUBLE)
    gg.toast("منضور الايباد يعمل الان ✔︎")
end

-- تفعيل الاستحواذ
function activatePossession()
    gg.clearResults()
    gg.setRanges(gg.REGION_C_DATA)
    gg.searchNumber("1065353216;720;486;30000;1001:17", gg.TYPE_FLOAT)
    gg.searchNumber("1065353216;720;486;30000;1001:17", gg.TYPE_DWORD)
    gg.refineNumber("1065353216", gg.TYPE_DWORD)
    local results = gg.getResults(10)
    savedValues = {}
    for i, v in ipairs(results) do
        savedValues[i] = {address = v.address, flags = gg.TYPE_DWORD, value = v.value}
    end
    gg.editAll("1063199999", gg.TYPE_DWORD)
    gg.alert(" تم تفعيل الاستحواذ ✔︎")
end

-- إلغاء المباراة (سرعة بطيئة)
function cancelMatch()
    gg.setSpeed(0.25)
    gg.alert("تم الغاء المباراه ✔︎!")
end

-- إعادة ضبط جميع القيم
function resetAll()
    gg.setSpeed(1.0)
    if #savedValues > 0 then
        gg.setValues(savedValues)
    end
    gg.alert("🔄 تم إعادة ضبط جميع القيم إلى الأصل")
end

-- قائمة السرعة
function speedMenu()
    while true do
        local choice = gg.choice({
            "⏲︎ تسريع الوقت x2",
            "⏲︎ تسريع الوقت x3",
            "⏲︎ تسريع الوقت x5",
            "⏲︎ تسريع الوقت x10",
            "⏲︎ إيقاف تسريع الوقت",
            "🔙 رجوع"
        }, nil, "☰ قائمة السرعة")
        
        if choice == 1 then
            gg.setSpeed(2.0)
            gg.alert("⏲︎ تم تفعيل السرعة ×2")
        elseif choice == 2 then
            gg.setSpeed(3.0)
            gg.alert("⏲︎ تم تفعيل السرعة ×3")
        elseif choice == 3 then
            gg.setSpeed(5.0)
            gg.alert("⏲︎ تم تفعيل السرعة ×5")
        elseif choice == 4 then
            gg.setSpeed(10.0)
            gg.alert("⏲︎ تم تفعيل السرعة ×10")
        elseif choice == 5 then
            gg.setSpeed(1.0)
            gg.alert("⏲︎ تم إيقاف التسريع")
        else
            break
        end
    end
end

-- قائمة البكجات
function packsMenu()
    while true do
        local choice = gg.choice({
            "®︎ بكج بيليه",
            "✯ بكج بلتز كير",
            "✯ بكج نجوم الأسبوع",
            "♛ جميع البكجات",
            "🔙 رجوع"
        }, nil, "☰ قائمة البكجات")
        
        if choice == 1 then
            gg.alert("®︎ تم فتح بكج بيليه")
        elseif choice == 2 then
            gg.alert("✯ تم فتح بكج بلتز كير")
        elseif choice == 3 then
            gg.alert("✯ تم فتح بكج نجوم الأسبوع")
        elseif choice == 4 then
            gg.alert("♛ تم فتح جميع البكجات")
        else
            break
        end
    end
end

-- وظيفة عرض معلومات التصحيح
function showDebugInfo()
    local expiryContent = downloadFromGitHub("https://raw.githubusercontent.com/karar-les/script-control9/main/expiry.txt")
    local expiryTime = expiryContent and tonumber(expiryContent:match("%d+")) or 0
    local expiryDate = os.date("%Y/%m/%d %H:%M:%S", expiryTime)
    
    local versionContent = downloadFromGitHub(GITHUB_VERSION_URL) or "غير متاح"
    
    gg.alert([[
معلومات التصحيح:

📌 الإصدار الحالي: ]]..SCRIPT_VERSION..[[

📌 الإصدار على الإنترنت: ]]..tostring(cleanVersion(versionContent))..[[

📌 تاريخ الانتهاء: ]]..expiryDate..[[

📌 حالة التحديث: ]]..tostring(checkForUpdates())..[[

📌 مسار السكربت: ]]..debug.getinfo(1).source:sub(2)..[[

📌 وقت التشغيل: ]]..os.date("%H:%M:%S", os.time() - startTime)..[[
]])
end

-- القائمة الرئيسية المعدلة
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
                "🐛 معلومات التصحيح", -- خيار جديد
                "✖︎ خروج"
            }, nil, "احذر التقليد تلكرام @TUX3T")
            
            if menu == 1 then
                local matchChoice = gg.choice({
                    "®︎ تفعيل الاستحواذ",
                    "®︎ تفعيل منضور الايباد",
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
                showDebugInfo()
                
            elseif menu == 7 then
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
