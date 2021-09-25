import { modules as ls } from "./builtins/ls";
import { modules as da } from "./builtins/da";
import { modules as nullls } from "./builtins/null-ls";
import { modules as tools } from "./builtins/tools";

export class ModulesState {
  static init(user_modules?: Modules | undefined) {
    ModulesState.user_modules = user_modules ?? {};
  }
  private static builtin_modules: Readonly<ModuleNames> = {
    ls,
    da,
    nullls,
    tools,
  };
  private static user_modules: Modules = {};
  private static modules_cache: ModuleNames | null = null;
  static get modules() {
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
    ModulesState.modules_cache = m;
    return m;
  }
  static set_user_module(category: string, name: string, mod: Module) {
    if (!this.user_modules[category]) {
      this.user_modules[category] = {};
    }
    this.user_modules[category][name] = mod;
    this.modules_cache = null;
  }
}

export class HooksState {
  static init(hooks?: Hooks | undefined) {
    HooksState.hooks = hooks ?? {};
  }
  private static hooks: Hooks;
  static get_hook(type: string, timing: "pre" | "post") {
    if (this.hooks[type]) {
      return this.hooks[type][timing] ?? [];
    }
    return [];
  }
}
