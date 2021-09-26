import { modules as ls } from "./builtins/ls";
import { modules as da } from "./builtins/da";
import { modules as nullls } from "./builtins/null-ls";
import { modules as tools } from "./builtins/tools";

export class modules_state {
  static init(user_modules?: Modules | undefined) {
    this.user_modules = user_modules ?? {};
  }
  private static builtin_modules: Readonly<ModuleNames> = {
    ls,
    da,
    nullls,
    tools,
  };
  private static user_modules: Modules = {};
  private static modules_cache: ModuleNames | null = null;
  static get_modules() {
    if (this.modules_cache) {
      return this.modules_cache;
    }
    let m = { ...this.builtin_modules };
    Object.entries(this.user_modules).forEach(([category_name, category]) => {
      Object.keys(category).forEach((module_name) => {
        if (!m[category_name]) m[category_name] = new Set();
        m[category_name].add(module_name);
      });
    });
    this.modules_cache = m;
    return m;
  }
  static get_module(category: string, name: string) {
    if (this.builtin_modules[category]) {
      if (this.builtin_modules[category].has(name)) {
        return require(`installer.builtins.${category}.${name}`) as Module;
      }
    } else {
      if (this.user_modules[category]) {
        if (this.user_modules[category][name]) {
          return this.user_modules[category][name];
        }
      }
    }
    return null;
  }
  static set_user_module(category: string, name: string, mod: Module) {
    if (!this.user_modules[category]) {
      this.user_modules[category] = {};
    }
    this.user_modules[category][name] = mod;
    this.modules_cache = null;
  }
}

export class hooks_state {
  static init(hooks?: Hooks | undefined) {
    this.hooks = hooks ?? {};
  }
  private static hooks: Hooks;
  static get_hook(type: string, timing: "pre" | "post") {
    if (this.hooks[type]) {
      return this.hooks[type][timing] ?? [];
    }
    return [];
  }
}
