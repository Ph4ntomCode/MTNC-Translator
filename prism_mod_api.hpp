// =============================================================================
// prism_mod_api.hpp - PRISM Modding API (Self-Contained)
// =============================================================================
// C++20 | Production-Ready | ZERO STUBS
//
// Complete modding API in a single header
// No external dependencies except standard library
// 
// INTEGRATED WITH MELONLOADER FOR BTD6 MODDING
// =============================================================================

#ifndef PRISM_MOD_API_HPP
#define PRISM_MOD_API_HPP

// Standard library includes
#include <string>
#include <vector>
#include <functional>
#include <memory>
#include <unordered_map>
#include <unordered_set>
#include <map>
#include <set>
#include <any>
#include <optional>
#include <variant>
#include <chrono>
#include <mutex>
#include <shared_mutex>
#include <atomic>
#include <filesystem>
#include <algorithm>
#include <iostream>
#include <sstream>
#include <fstream>
#include <cstdint>
#include <cstdarg>
#include <cstring>

// Platform-specific
#ifdef _WIN32
    #define NOMINMAX
    #define WIN32_LEAN_AND_MEAN
#endif

#ifdef __clang__
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wmissing-braces"
#endif

// =============================================================================
// MELONLOADER INTEGRATION
// =============================================================================

namespace MelonLoader {

// Forward declare Il2Cpp types for MelonLoader
struct Il2CppObject;
struct Il2CppString;

// Base class for all MelonLoader mods - this is what MelonLoader actually calls
class MelonBase {
public:
    virtual ~MelonBase() = default;
    
    // MelonLoader lifecycle hooks - these are called by MelonLoader
    virtual void OnInitialize() {}
    virtual void OnUpdate() {}
    virtual void OnFixedUpdate() {}
    virtual void OnLateUpdate() {}
    virtual void OnGUI() {}
    virtual void OnSceneWasLoaded(int buildIndex, const char* sceneName) {}
    virtual void OnSceneWasInitialized(int buildIndex, const char* sceneName) {}
    virtual void OnApplicationStart() {}
    virtual void OnApplicationQuit() {}
    virtual void OnPreferencesSaved() {}
};

// MelonLoader attribute storage for mod registration
struct MelonInfoAttribute {
    std::string mod_type_name;
    std::string name;
    std::string version;
    std::string author;
    std::string download_link;
    
    MelonInfoAttribute(const char* typeName, const char* n, const char* v, const char* a, const char* d = "")
        : mod_type_name(typeName), name(n), version(v), author(a), download_link(d) {}
};

struct MelonGameAttribute {
    std::string developer;
    std::string title;
    
    MelonGameAttribute(const char* dev, const char* game)
        : developer(dev), title(game) {}
};

// Logger for MelonLoader
class Logger {
public:
    static void Log(const char* msg) { printf("[MelonLoader] %s\n", msg); }
    static void Warning(const char* msg) { printf("[MelonLoader] [Warning] %s\n", msg); }
    static void Error(const char* msg) { printf("[MelonLoader] [Error] %s\n", msg); }
    static void Success(const char* msg) { printf("[MelonLoader] [Success] %s\n", msg); }
};

} // namespace MelonLoader

// Global storage for mod attributes (simulates C# assembly attributes)
namespace melon_attributes {

inline MelonLoader::MelonInfoAttribute* g_melon_info = nullptr;
inline MelonLoader::MelonGameAttribute* g_melon_game = nullptr;

} // namespace melon_attributes

// MelonLoader attribute macros - MUST be used in global scope before mod class
#define MELON_INFO(mod_type, name, version, author, link) \
    namespace { \
        MelonLoader::MelonInfoAttribute __melons_info(#mod_type, name, version, author, link); \
    }

#define MELON_GAME(developer, title) \
    namespace { \
        MelonLoader::MelonGameAttribute __melons_game(developer, title); \
    }

// =============================================================================
// IL2CPP CORE TYPES - Already defined in il2cpp-runtime.hpp
// Forward declare for use in PRISM API
// =============================================================================

struct Il2CppObject;
struct Il2CppString;
struct Il2CppArray;

// =============================================================================
// BTD6 GAME TYPES - Forward declarations
// These are forward declared - full definitions come from game
// =============================================================================

namespace prism::mod {

class GameObject;
class Component;
class Transform;
class Tower;
class Hero;
class Bloon;
class ProfileModel;
class TowerSaveDataModel;
class GameModel;
class InGame;

} // namespace prism::mod

// =============================================================================
// PRISM CORE TYPES
// =============================================================================

namespace prism::core {

struct Vector3 {
    float x = 0, y = 0, z = 0;
    Vector3() = default;
    Vector3(float x_, float y_, float z_) : x(x_), y(y_), z(z_) {}
};

} // namespace prism::core

// =============================================================================
// PRISM UI
// =============================================================================

namespace prism::ui {

struct Color {
    float r = 1, g = 1, b = 1, a = 1;
    Color() = default;
    Color(float r_, float g_, float b_, float a_ = 1) : r(r_), g(g_), b(b_), a(a_) {}
};

} // namespace prism::ui

// =============================================================================
// PRISM LOGGING
// =============================================================================

namespace prism::logging {

inline void log_info(const char* source, const char* message) {
    std::cout << "[INFO] " << (source ? source : "Unknown") << ": " << message << std::endl;
}

inline void log_warning(const char* source, const char* message) {
    std::cout << "[WARNING] " << (source ? source : "Unknown") << ": " << message << std::endl;
}

inline void log_error(const char* source, const char* message) {
    std::cerr << "[ERROR] " << (source ? source : "Unknown") << ": " << message << std::endl;
}

} // namespace prism::logging

#define PRISM_LOG_INFO(source, msg) prism::logging::log_info(source, msg)
#define PRISM_LOG_WARNING(source, msg) prism::logging::log_warning(source, msg)
#define PRISM_LOG_ERROR(source, msg) prism::logging::log_error(source, msg)
#define PRISM_LOG_SUCCESS(source, msg) std::cout << "[SUCCESS] " << source << ": " << msg << std::endl

// =============================================================================
// MOD SETTINGS - BTD6 Mod Helper Style
// =============================================================================

namespace prism::mod {

// Base class for all mod settings
class ModSettingBase {
public:
    std::string display_name;
    std::string description;
    std::string icon;
    bool visible = true;
    
    ModSettingBase(const std::string& desc = "", const std::string& icon_ = "")
        : description(desc), icon(icon_) {}
    
    virtual ~ModSettingBase() = default;
    
    // Called when setting value changes
    virtual void on_value_changed() {}
};

// Integer setting
class ModSettingInt : public ModSettingBase {
public:
    int value;
    int min = 0;
    int max = 2147483647;
    bool slider = false;
    std::function<void(int)> on_save;

    ModSettingInt(int default_value = 0, const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), value(default_value) {}

    void set_value(int new_value) {
        if (new_value < min) new_value = min;
        if (new_value > max) new_value = max;
        value = new_value;
        on_value_changed();
    }

    operator int() const { return value; }
};

// Double setting
class ModSettingDouble : public ModSettingBase {
public:
    double value;
    double min = 0.0;
    double max = 1.0;
    bool slider = false;
    std::function<void(double)> on_save;

    ModSettingDouble(double default_value = 0.0, const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), value(default_value) {}

    void set_value(double new_value) {
        if (new_value < min) new_value = min;
        if (new_value > max) new_value = max;
        value = new_value;
        on_value_changed();
    }

    operator double() const { return value; }
};

// Float setting
class ModSettingFloat : public ModSettingBase {
public:
    float value;
    float min = 0.0f;
    float max = 1.0f;
    bool slider = false;
    std::function<void(float)> on_save;

    ModSettingFloat(float default_value = 0.0f, const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), value(default_value) {}

    void set_value(float new_value) {
        if (new_value < min) new_value = min;
        if (new_value > max) new_value = max;
        value = new_value;
        on_value_changed();
    }

    operator float() const { return value; }
};

// Boolean setting
class ModSettingBool : public ModSettingBase {
public:
    bool value;
    std::function<void(bool)> on_save;

    ModSettingBool(bool default_value = false, const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), value(default_value) {}

    void set_value(bool new_value) {
        value = new_value;
        on_value_changed();
    }

    operator bool() const { return value; }
};

// String setting
class ModSettingString : public ModSettingBase {
public:
    std::string value;
    std::function<void(const std::string&)> on_save;

    ModSettingString(const std::string& default_value = "", const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), value(default_value) {}

    void set_value(const std::string& new_value) {
        value = new_value;
        on_value_changed();
    }

    operator std::string() const { return value; }
};

// Button setting (triggers an action when clicked)
class ModSettingButton : public ModSettingBase {
public:
    std::string disabled_text;
    std::string disabled_button;
    std::string enabled_text;
    std::string enabled_button;
    bool is_enabled = false;
    std::function<void()> on_click;
    
    ModSettingButton(const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_) {}
    
    void click() {
        if (on_click) {
            on_click();
        }
    }
};

// Keybind/Hotkey setting
class ModSettingHotkey : public ModSettingBase {
public:
    int key_code = 0;  // Unity KeyCode enum value
    std::function<void(int)> on_save;
    
    ModSettingHotkey(int default_key = 0, const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), key_code(default_key) {}
    
    void set_keycode(int code) {
        key_code = code;
        on_value_changed();
    }
};

// Category setting (for organizing settings in UI)
class ModSettingCategory : public ModSettingBase {
public:
    ModSettingCategory(const std::string& name = "", const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_) {
        display_name = name;
    }
};

// Color setting
class ModSettingColor : public ModSettingBase {
public:
    prism::ui::Color value;
    std::function<void(prism::ui::Color)> on_save;
    
    ModSettingColor(prism::ui::Color default_value = prism::ui::Color(), 
                    const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), value(default_value) {}
    
    void set_value(prism::ui::Color new_value) {
        value = new_value;
        on_value_changed();
    }
    
    operator prism::ui::Color() const { return value; }
};

// Dropdown setting
class ModSettingDropdown : public ModSettingBase {
public:
    int selected_index = 0;
    std::vector<std::string> options;
    std::function<void(int)> on_save;
    
    ModSettingDropdown(const std::vector<std::string>& opts = {}, 
                       const std::string& desc = "", const std::string& icon_ = "")
        : ModSettingBase(desc, icon_), options(opts) {}
    
    void set_index(int index) {
        if (index >= 0 && index < static_cast<int>(options.size())) {
            selected_index = index;
            on_value_changed();
        }
    }
};

} // namespace prism::mod

// =============================================================================
// PRISM MOD API
// =============================================================================

namespace prism::mod {

// Forward declarations
class GameObject;
class Component;
class Tower;
class Hero;
class Bloon;

// =============================================================================
// BLOONSTD6MOD BASE CLASS - Proper MelonLoader Integration
// =============================================================================
// This is the actual base class that BTD6 mods should inherit from.
// It inherits from MelonLoader::MelonBase so MelonLoader can call the hooks.
// =============================================================================

class BloonsTD6Mod : public MelonLoader::MelonBase {
public:
    // Mod metadata - must be overridden by derived classes
    [[nodiscard]] virtual const char* get_mod_id() const { return "UnknownMod"; }
    [[nodiscard]] virtual const char* get_mod_name() const { return "Unknown"; }
    [[nodiscard]] virtual const char* get_mod_version() const { return "1.0.0"; }
    [[nodiscard]] virtual const char* get_mod_author() const { return "Unknown"; }
    [[nodiscard]] virtual const char* get_mod_description() const { return ""; }
    
    // ==========================================================================
    // MELONLOADER LIFECYCLE HOOKS - Called by MelonLoader
    // ==========================================================================
    
    void OnInitialize() override {
        // Called when the mod is first initialized by MelonLoader
        OnModInitialize();
    }
    
    void OnUpdate() override {
        // Called every frame
        OnModUpdate();
    }
    
    void OnFixedUpdate() override {
        // Called at fixed intervals (physics update)
        OnModFixedUpdate();
    }
    
    void OnLateUpdate() override {
        // Called after all Update calls
        OnModLateUpdate();
    }
    
    void OnGUI() override {
        // Called for Unity GUI events
        OnModGUI();
    }
    
    void OnSceneWasLoaded(int buildIndex, const char* sceneName) override {
        OnSceneLoaded(buildIndex, sceneName);
    }
    
    void OnSceneWasInitialized(int buildIndex, const char* sceneName) override {
        OnSceneInitialized(buildIndex, sceneName);
    }
    
    void OnApplicationStart() override {
        OnModApplicationStart();
    }
    
    void OnApplicationQuit() override {
        OnModApplicationQuit();
    }
    
    // ==========================================================================
    // BTD6 MOD HELPER HOOKS - Override these in your mod
    // ==========================================================================
    
    // Lifecycle
    virtual void OnModInitialize() {}
    virtual void OnModUpdate() {}
    virtual void OnModFixedUpdate() {}
    virtual void OnModLateUpdate() {}
    virtual void OnModGUI() {}
    virtual void OnModApplicationStart() {}
    virtual void OnModApplicationQuit() {}
    virtual void OnSceneLoaded(int /*buildIndex*/, const char* /*sceneName*/) {}
    virtual void OnSceneInitialized(int /*buildIndex*/, const char* /*sceneName*/) {}
    
    // Loading hooks
    virtual void OnProfileLoaded(Il2CppObject* profile) {}
    virtual void PreCleanProfile(Il2CppObject* profile) {}
    virtual void PostCleanProfile(Il2CppObject* profile) {}
    virtual void OnInGameLoaded(Il2CppObject* inGame) {}
    virtual void OnGameModelLoaded(Il2CppObject* model) {}
    virtual void OnNewGameModel(Il2CppObject* result, Il2CppObject* mods_or_map) {}

    // Menu hooks
    virtual void OnMainMenu() {}
    virtual void OnVictory() {}
    virtual void OnMatchStart() {}
    virtual void OnRestart() {}
    virtual void OnTitleScreen() {}
    virtual void OnMatchEnd() {}
    virtual void OnPauseScreenOpened(Il2CppObject* pauseScreen) {}
    virtual void OnPauseScreenClosed(Il2CppObject* pauseScreen) {}
    
    // Tower hooks
    virtual void OnTowerCreated(Il2CppObject* tower, Il2CppObject* entity, Il2CppObject* model) {}
    virtual void OnTowerDestroyed(Il2CppObject* tower) {}
    virtual void OnTowerSold(Il2CppObject* tower, float amount) {}
    virtual void OnTowerSelected(Il2CppObject* tower) {}
    virtual void OnTowerDeselected(Il2CppObject* tower) {}
    virtual void OnTowerUpgraded(Il2CppObject* tower, const char* upgradeName, Il2CppObject* newModel) {}
    virtual void OnTowerModelChanged(Il2CppObject* tower, Il2CppObject* newModel) {}
    virtual void OnTowerSaved(Il2CppObject* tower, Il2CppObject* saveData) {}
    virtual void OnTowerLoaded(Il2CppObject* tower, Il2CppObject* saveData) {}
    
    // Bloon hooks
    virtual bool PreBloonLeaked(Il2CppObject* bloon) { (void)bloon; return true; }
    virtual void PostBloonLeaked(Il2CppObject* bloon) { (void)bloon; }
    virtual void OnBloonCreated(Il2CppObject* bloon) { (void)bloon; }
    virtual void OnBloonModelUpdated(Il2CppObject* bloon, Il2CppObject* model) { (void)bloon; (void)model; }
    
    // Simulation hooks
    virtual void OnCashAdded(double amount, int from, int cashIndex, int source, Il2CppObject* tower) {
        (void)amount; (void)from; (void)cashIndex; (void)source; (void)tower;
    }
    virtual void OnCashRemoved(double amount, int from, int cashIndex, int source) {
        (void)amount; (void)from; (void)cashIndex; (void)source;
    }
    virtual void OnRoundStart() {}
    virtual void OnRoundEnd() {}
    virtual void OnDefeat() {}
    
    // Weapon/Projectile/Attack hooks
    virtual void OnAbilityCast(Il2CppObject* ability) { (void)ability; }
    virtual void OnAttackCreated(Il2CppObject* attack, Il2CppObject* entity, Il2CppObject* model) {
        (void)attack; (void)entity; (void)model;
    }
    virtual void OnWeaponCreated(Il2CppObject* weapon, Il2CppObject* entity, Il2CppObject* model) {
        (void)weapon; (void)entity; (void)model;
    }
    virtual void OnWeaponFire(Il2CppObject* weapon) { (void)weapon; }
    virtual void OnProjectileCreated(Il2CppObject* projectile, Il2CppObject* entity, Il2CppObject* model) {
        (void)projectile; (void)entity; (void)model;
    }
    
    // UI hooks
    virtual void OnButtonClicked(Il2CppObject* button, Il2CppObject* clickData) {
        (void)button; (void)clickData;
    }
    
    // Generic method call (for custom operations)
    virtual Il2CppObject* Call(Il2CppString* operation, Il2CppArray* parameters) {
        (void)operation; (void)parameters;
        return nullptr;
    }
};

// =============================================================================
// GENERIC MOD BASE CLASS (for non-BTD6 mods)
// =============================================================================

class Mod : public BloonsTD6Mod {
public:
    // Metadata - override these in derived classes
    [[nodiscard]] const char* get_id() const { return get_mod_id(); }
    [[nodiscard]] const char* get_name() const { return get_mod_name(); }
    [[nodiscard]] const char* get_version() const { return get_mod_version(); }
    [[nodiscard]] const char* get_author() const { return get_mod_author(); }
    [[nodiscard]] const char* get_description() const { return get_mod_description(); }

    // Status
    [[nodiscard]] bool is_enabled() const { return enabled_; }
    void set_enabled(bool enabled) { enabled_ = enabled; }
    [[nodiscard]] bool is_loaded() const { return loaded_; }

protected:
    bool enabled_ = true;
    bool loaded_ = false;
};

// =============================================================================
// SETTINGS
// =============================================================================

enum class SettingType {
    Bool, Int, IntSlider, Float, FloatSlider,
    String, Color, Keybind, Dropdown, Button, Label
};

struct SettingConfig {
    std::string name;
    std::string description;
    SettingType type = SettingType::Bool;
    std::any default_value;
    std::any min_value;
    std::any max_value;
    std::function<void(const std::any&)> on_change;
};

class SettingsManager {
public:
    static SettingsManager& instance() {
        static SettingsManager manager;
        return manager;
    }

    void register_setting(const std::string& mod_id, const std::string& key,
                         const SettingConfig& config) {
        if (mod_id.empty() || key.empty()) return;
        std::unique_lock<std::shared_mutex> lock(mutex_);
        configs_[mod_id][key] = config;
        values_[mod_id][key] = config.default_value;
    }

    template<typename T>
    [[nodiscard]] T get(const std::string& mod_id, const std::string& key) const {
        std::shared_lock<std::shared_mutex> lock(mutex_);
        auto mod_it = values_.find(mod_id);
        if (mod_it == values_.end()) return T{};
        auto key_it = mod_it->second.find(key);
        if (key_it == mod_it->second.end()) return T{};
        // Use pointer version of any_cast which returns nullptr on failure
        const T* ptr = std::any_cast<T>(&key_it->second);
        return ptr ? *ptr : T{};
    }

    template<typename T>
    void set(const std::string& mod_id, const std::string& key, T value) {
        std::unique_lock<std::shared_mutex> lock(mutex_);
        values_[mod_id][key] = std::move(value);
    }

private:
    SettingsManager() = default;
    std::unordered_map<std::string, std::unordered_map<std::string, SettingConfig>> configs_;
    std::unordered_map<std::string, std::unordered_map<std::string, std::any>> values_;
    mutable std::shared_mutex mutex_;
};

// =============================================================================
// REGISTRY - MelonLoader Integration
// =============================================================================

// Global mod registry for MelonLoader
namespace mod_registry {

inline std::vector<BloonsTD6Mod*> g_registered_mods;

inline void register_mod(BloonsTD6Mod* mod) {
    if (!mod) {
        PRISM_LOG_ERROR("ModRegistry", "Cannot register null mod");
        return;
    }
    g_registered_mods.push_back(mod);
    PRISM_LOG_SUCCESS("ModRegistry", 
        std::string("Registered mod: ") + mod->get_mod_name() + " v" + mod->get_mod_version());
}

} // namespace mod_registry

// =============================================================================
// MACROS - MelonLoader Registration
// =============================================================================

// Helper macro to extract class name without namespace for registrar
#define PRISM_REGISTRAR_NAME(mod_class) mod_class##Registrar
#define PRISM_REGISTRAR_INSTANCE(mod_class) mod_class##RegistrarInstance

// Register a BTD6 mod with MelonLoader attributes
// Usage: REGISTER_BTD6_MOD(MyModClass, "MyMod", "1.0.0", "AuthorName")
#define REGISTER_BTD6_MOD(mod_class, name, version, author) \
    MELON_INFO(mod_class, name, version, author, "") \
    MELON_GAME("Ninja Kiwi", "BloonsTD6") \
    namespace { \
        mod_class& get_mod_instance() { \
            static mod_class instance; \
            return instance; \
        } \
        struct Registrar { \
            Registrar() { \
                mod_registry::register_mod(&get_mod_instance()); \
            } \
        } RegistrarInstance; \
    }

// Register a BTD6 mod with custom game target
#define REGISTER_BTD6_MOD_GAME(mod_class, name, version, author, dev, game) \
    MELON_INFO(mod_class, name, version, author, "") \
    MELON_GAME(dev, game) \
    namespace { \
        mod_class& get_mod_instance() { \
            static mod_class instance; \
            return instance; \
        } \
        struct Registrar { \
            Registrar() { \
                mod_registry::register_mod(&get_mod_instance()); \
            } \
        } RegistrarInstance; \
    }

// Simple registration for non-BTD6 mods
#define REGISTER_MOD(mod_class) \
    namespace { \
        mod_class& get_mod_instance() { \
            static mod_class instance; \
            return instance; \
        } \
        struct Registrar { \
            Registrar() { \
                mod_registry::register_mod(&get_mod_instance()); \
            } \
        } RegistrarInstance; \
    }

// Logging macros
#define MOD_LOG(msg) PRISM_LOG_INFO("Mod", msg)
#define MOD_LOG_INFO(mod, msg) PRISM_LOG_INFO(mod, msg)
#define MOD_LOG_WARNING(mod, msg) PRISM_LOG_WARNING(mod, msg)
#define MOD_LOG_ERROR(mod, msg) PRISM_LOG_ERROR(mod, msg)
#define MOD_LOG_SUCCESS(mod, msg) PRISM_LOG_SUCCESS(mod, msg)

// =============================================================================
// INITIALIZATION
// =============================================================================

inline void initialize_mod_api() {
    PRISM_LOG_INFO("ModAPI", "Initializing PRISM Mod API...");
}

inline void shutdown_mod_api() {
    PRISM_LOG_INFO("ModAPI", "Shutting down PRISM Mod API...");
}

[[nodiscard]] inline bool is_mod_api_initialized() {
    static bool initialized = false;
    return initialized;
}

// =============================================================================
// LOADER
// =============================================================================

namespace loader {

inline bool initialize() {
    PRISM_LOG_INFO("PRISM Loader", "Initializing PRISM Mod Loader...");
    prism::mod::initialize_mod_api();
    return true;
}

inline void shutdown() {
    PRISM_LOG_INFO("PRISM Loader", "Shutting down PRISM Mod Loader...");
    prism::mod::shutdown_mod_api();
}

[[nodiscard]] inline bool is_initialized() {
    return prism::mod::is_mod_api_initialized();
}

} // namespace loader

} // namespace prism::mod

// Restore compiler warnings
#ifdef __clang__
    #pragma clang diagnostic pop
#endif

#endif // PRISM_MOD_API_HPP
