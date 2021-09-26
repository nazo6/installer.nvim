import { modules_state } from "./state";

export class display {
  private static display_handle: null | number = null;
  static open() {
    if (!this.display_handle) {
      vim.cmd("65vnew");
      this.display_handle = vim.api.nvim_get_current_buf();
    }
  }
  static install(category: string, name: string) {
    if (!this.display_handle) return;
    const module = modules_state.get_module(category, name);
    if (!module) return;
  }
}
