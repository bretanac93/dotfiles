return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<Leader>dt",
        function()
          require("dap").toggle_breakpoint()
        end,
      },
      {
        "<Leader>dc",
        function()
          require("dap").continue()
        end,
      },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go"
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("dap-go").setup()
      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  {},
}
