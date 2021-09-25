import { ModulesState, HooksState } from "./state";
import * as display from "./display";

type Config = {
  ensure_installed?: ModuleNames;
  custom_modules?: Modules;
  hooks?: any;
};
export function setup(user_config: Config) {
  const { ensure_installed, hooks, custom_modules, ...options } = user_config;
  if (ensure_installed) {
    for (const category in ensure_installed) {
      ensure_installed[category].forEach((name) => {
        install(category, name);
      });
    }
  }
  HooksState.init(hooks);
  ModulesState.init(custom_modules);
}

export async function install(category: string, name: string) {
  display.open();
  display.install(category, name);
}
