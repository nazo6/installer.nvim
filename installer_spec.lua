local mock = require "luassert.mock"
local stub = require "luassert.stub"

local install = require("lspinstall").install_server

local servers = require "lspinstall/servers"

describe("installers", function()
  for lang, config in pairs(servers) do
    it('install "' .. lang .. '" successfully', function()
      async()
      install(lang, function(code)
        assert.equals(code, 0)
        done()
      end)
    end)
  end
end)
