type Module = {
  install_script: (category: string, name: string) => string;
  update_script?: (category: string, name: string) => string;
  uninstall_script?: (category: string, name: string) => string;
};
type Category = {
  [module_name: string]: Module;
};
type Modules = {
  [category: string]: Category;
};

type ModuleNames = {
  [category: string]: Set<string>;
};

type Hooks = {
  [type: string]: {
    pre: Array<(category: string, name: string) => void>;
    post: Array<(category: string, name: string) => void>;
  };
};
