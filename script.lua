--[[
🔥 سكريبت محمد الشمري - الإصدار 1.0.2 🔥
--]]

-- ======= إعدادات النظام الأساسية =======
local savedValues = {}
local startTime = os.time()
local PASSWORD = "TUX3T"
local EXPIRE_DATE = os.time({year = 2025, month = 12, day = 31})
local fancyMessages = {"محمد الشمري يرحب بكم"}
local SCRIPT_VERSION = "1.0.2"
local GITHUB_REPO = "karar-les/script-control9"
local GITHUB_BRANCH = "main"
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/"..GITHUB_REPO.."/"..GITHUB_BRANCH.."/script.lua"
local GITHUB_VERSION_URL = "https://raw.githubusercontent.com/"..GITHUB_REPO.."/"..GITHUB_BRANCH.."/version.txt"
local GITHUB_EXPIRY_URL = "https://raw.githubusercontent.com/"..GITHUB_REPO.."/"..GITHUB_BRANCH.."/expiry.txt"
local DEBUG_MODE = true -- ضعها false لتعطيل رسائل التصحيح

-- ======= دوال النظام الأساسية =======

-- وظيفة تنزيل الملف من GitHub مع معالجة الأخطاء
function downloadFromGitHub(url)
    local success, result = pcall(gg.makeRequest, {
        url = url,
        headers = {
            ["Cache-Control"] = "no-cache",
            ["Pragma"] = "no-cache"
        }
    })
    
    if DEBUG_MODE then
        print("طلب URL:", url)
        print("الحالة:", success)
        print("النتيجة:", result and #result.content or "لا يوجد محتوى")
    end
    
    if success and result and result.content and #result.content > 10 then
        return result.content
    end
    return nil
end

-- تنظيف نص الإصدار من أي شوائب
function cleanVersion(versionText)
    if not versionText then return nil end
    local cleaned = versionText:gsub("%s+", ""):gsub("[\r\n]+", "")
    return cleaned:match("(%d+%.%d+%.%d+)") or cleaned
end

-- ======= نظام التحديث المحسن =======

function checkForUpdates()
    gg.toast("🔍 جاري التحقق من التحديثات...", true)
    
    -- التحقق من الإصدار أولاً
    local onlineVersionContent = downloadFromGitHub(GITHUB_VERSION_URL)
    local onlineVersion = cleanVersion(onlineVersionContent)
    local currentVersion = cleanVersion(SCRIPT_VERSION)
    
    if DEBUG_MODE then
        print("الإصدار الحالي:", currentVersion)
        print("الإصدار على الإنترنت:", onlineVersion)
    end
    
    if not onlineVersion or not currentVersion then
        gg.toast("⚠️ تنسيق الإصدار غير صحيح", true)
        return false
    end
    
    if onlineVersion ~= currentVersion then
        local updateMessage = string.format(
            "يتوفر تحديث جديد (%s)!\n\nالإصدار الحالي: %s\n\nهل تريد التحديث الآن؟",
            onlineVersion, currentVersion
        )
        
        local choice = gg.alert(updateMessage, "نعم", "لا")
        
        if choice == 1 then
            gg.toast("⏳ جاري تنزيل التحديث...", true)
            local newScript = downloadFromGitHub(GITHUB_RAW_URL)
            
            if newScript and #newScript > 1000 then -- التأكد من حجم معقول للسكربت
                local scriptPath = debug.getinfo(1).source:sub(2)
                local backupPath = scriptPath..".bak_"..os.time()
                
                -- إنشاء نسخة احتياطية
                if os.rename(scriptPath, backupPath) then
                    local file, err = io.open(scriptPath, "w")
                    if file then
                        file:write(newScript)
                        file:close()
                        
                        -- التحقق من أن الملف الجديد غير فارغ
                        local verify = io.open(scriptPath, "r")
                        if verify then
                            local content = verify:read("*a")
                            verify:close()
                            
                            if #content > 1000 then
                                gg.alert("✅ تم التحديث بنجاح!\n\nسيتم إعادة التشغيل تلقائياً.")
                                
                                -- إعادة التشغيل باستخدام تأخير
                                os.execute("sleep 2 && am start -n com.android.gp/com.android.gp.GameActivity && lua "..scriptPath.." &")
                                os.exit()
                                return true
                            end
                        end
                    end
                end
                
                -- إذا وصلنا هنا يعني حدث خطأ
                gg.alert("❌ فشل تطبيق التحديث\nسيتم استعادة النسخة القديمة")
                os.rename(backupPath, scriptPath)
            else
                gg.alert("❌ فشل تنزيل السكربت الجديد أو الملف غير صالح")
            end
        end
    else
        gg.toast("✔️ أنت تستخدم أحدث إصدار ("..currentVersion..")", true)
    end
    return false
end

-- ======= دوال التحقق والصلاحية =======

function checkOnlineExpiry()
    gg.toast("🔍 جاري التحقق من الصلاحية...", true)
    local expiryContent = downloadFromGitHub(GITHUB_EXPIRY_URL)
    
    if not expiryContent then
        gg.alert("⚠️ تعذر التحقق من الصلاحية عبر الإنترنت\nسيتم استخدام التاريخ المحلي")
        return false
    end
    
    local onlineExpiry = tonumber(expiryContent:match("%d+"))
    if not onlineExpiry then return false end
    
    local now = os.time()
    if now > onlineExpiry then
        gg.alert("تم انتهاء صلاحية السكربت\nللاشتراك تواصل @TUX3T")
        os.exit()
    end
    
    if onlineExpiry < EXPIRE_DATE then
        EXPIRE_DATE = onlineExpiry
        if (EXPIRE_DATE - now) < 86400 then
            gg.alert("تنتهي صلاحية السكربت خلال 24 ساعة ⏳")
        end
    end
    
    return true
end

function checkAuth()
    gg.alert("☪️ محمد الشمري ☪️\n\nتواصل @TUX3T")
    
    -- التحقق من التحديثات أولاً
    checkForUpdates()
    
    local input = gg.prompt({"🔑 أدخل كلمة المرور:"}, nil, {"text"})
    if not input or input[1] ~= PASSWORD then
        gg.alert("كلمة المرور خاطئة!")
        os.exit()
    end

    -- التحقق من الصلاحية
    if not checkOnlineExpiry() then
        local now = os.time()
        if now > EXPIRE_DATE then
            gg.alert("انتهت صلاحية السكربت\nتواصل @TUX3T للتجديد")
            os.exit()
        elseif (EXPIRE_DATE - now) < 86400 then
            gg.alert("تنتهي الصلاحية خلال 24 ساعة!")
        end
    end

    gg.alert("مرحباً بك! استمتع باستخدام السكربت")
end

-- ======= دوال الميزات =======
-- (أبقِ دوال iPadView, activatePossession, cancelMatch, resetAll, speedMenu, packsMenu كما هي)

-- ======= القائمة الرئيسية المحسنة =======

function mainMenu()
    local menuItems = {
        "🎮 قائمة المباراة",
        "⚡ قائمة السرعة",
        "🎁 قائمة البكجات",
        "🔄 إعادة الضبط",
        "🔃 التحقق من التحديثات",
        "ℹ️ معلومات السكربت",
        "🚪 خروج"
    }
    
    while true do
        if gg.isVisible(true) then
            gg.setVisible(false)
            local choice = gg.choice(menuItems, nil, "سكربت محمد الشمري - v"..SCRIPT_VERSION)
            
            if choice == 1 then -- قائمة المباراة
                local matchChoice = gg.choice({
                    "تفعيل الاستحواذ",
                    "وضع iPad",
                    "إلغاء المباراة",
                    "العودة"
                }, nil, "قائمة المباراة")
                
                -- معالجة الخيارات...
                
            elseif choice == 5 then -- التحقق من التحديثات
                checkForUpdates()
                
            elseif choice == 7 then -- خروج
                gg.alert("شكراً لاستخدامك السكربت!")
                os.exit()
            end
        end
        gg.sleep(300)
    end
end

-- ======= بدء التشغيل =======
checkAuth()
mainMenu()
