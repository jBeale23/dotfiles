-- ---------- --
-- Appearance --
-- ---------- --
vim.g.have_nerd_font = true -- Enables the use of nerd font glyphs
vim.api.nvim_create_autocmd("WinEnter", {
	desc = "Enable Cursorline/column when entering a window.",
	group = vim.api.nvim_create_augroup("find-cursor", { clear = true }),
	callback = function()
		vim.o.cursorline = true
		vim.o.cursorcolumn = true
	end,
})
vim.api.nvim_create_autocmd("WinLeave", {
	desc = "Disable Cursorline/column when leaving a window.",
	group = vim.api.nvim_create_augroup("find-cursor", { clear = true }),
	callback = function()
		vim.o.cursorline = false
		vim.o.cursorcolumn = false
	end,
})
vim.o.scrolloff = 10 -- Keep a minimum of 10 lines above and below the cursor when possible
vim.o.showmode = false -- Disable typical mode display, as mini.statusline is enabled
vim.o.signcolumn = "yes" -- Enable sign column for git signs
vim.o.splitright = true -- Split panes to the right
vim.o.splitbelow = true -- Split panes downwards
vim.o.wrap = true -- Wrap long lines
vim.o.breakindent = true -- When wrapping lines, continue them at the same indent level
vim.o.list = true -- Shows otherwise hidden characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- Configures display for hidden characters
vim.o.number = true -- Shows cursor line number
vim.o.relativenumber = true -- Shows relative line number for jumps
vim.o.tabstop = 2 -- Sets tabs to be 2 spaces
vim.o.shiftwidth = 2 -- Sets auto indenting to use 2 spaces

-- ----------------- --
-- User Friendliness --
-- ----------------- --
vim.o.mouse = "a" -- Enable Mouse Mode
vim.o.mousehide = true -- Hides the mouse while typing
vim.o.confirm = true -- Confirms when trying to quit without saving
vim.o.undofile = true -- Extended undo history per-file
vim.o.inccommand = "split" -- Shows command effects on buffer
vim.o.autoindent = true -- Automatically indents text
vim.o.smartindent = true -- Makes indenting smarter for C-style languages
vim.o.ignorecase = true -- Makes searching case insensitive
vim.o.smartcase = true -- Makes searching case sensitive if there are capital letters in the search
vim.schedule(function()
	vim.o.clipboard = "unnamedplus" -- Use system clipboard
end)
vim.api.nvim_create_autocmd("TextYankPost", { -- Highlight when copying text
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- ------- --
-- Plugins --
-- ------- --
local mini_deps_installed, MiniDeps = pcall(require, "mini.deps") -- Bootstrap minideps to automate plugin setup
if not mini_deps_installed then
	vim.notify("[WARN] mini.deps module not found, attempting to bootstrap.", vim.log.levels.WARN)
	local path_package = vim.fn.stdpath("data") .. "/site"
	local mini_path = path_package .. "/pack/deps/start/mini.nvim"
	if not vim.loop.fs_stat(mini_path) then
		vim.cmd('echo "Installing `mini.nvim`" | redraw')
		local clone_cmd = {
			"git",
			"clone",
			"--filter=blob:none",
			"--branch",
			"stable",
			"https://github.com/nvim-mini/mini.nvim",
			mini_path,
		}
		vim.fn.system(clone_cmd)
		vim.cmd("packadd mini.nvim | helptags ALL")
		vim.cmd('echo "Installed `mini.nvim`" | redraw')
	end
end

MiniDeps.setup({})
---@param plugin string Github name and repository, or internal mini plugin
---@param checkout? string Version tag to checkout
---@param options? table Configuration options for the plugin
local function add_plugin(plugin, checkout, options)
	checkout = checkout or nil
	options = options or {}
	if checkout ~= nil then
		MiniDeps.add({
			source = plugin,
			checkout = checkout,
		})
	end
	function string.split(str, sep)
		local t = {}
		local pattern = "([^" .. sep .. "]+)"
		for match in string.gmatch(str, pattern) do
			table.insert(t, match)
		end
		return t
	end

	local plugin_name
	if plugin:find("/") then
		local plugin_name_table = plugin:split("/")
		plugin_name = plugin_name_table[#plugin_name_table]
	else
		plugin_name = plugin
	end

	if plugin_name:find("%.nvim") then
		plugin_name = plugin_name:gsub("%.nvim", "")
	end
	local ok, mod = pcall(require, plugin_name)
	if ok and type(mod.setup) == "function" then
		mod.setup(options)
	end
end

add_plugin("mini.statusline", nil, {
	use_icons = vim.g.have_nerd_font,
	section_location = function()
		return "%2l:%-2v"
	end,
}) -- Statusline showing warnings, git branch, etc.
add_plugin("mini.completion", nil, {}) -- Adds basic completion capabilities
add_plugin("mini.icons", nil, { style = "glyph" }) -- Adds icons to LSP autocomplete hints
MiniDeps.later(MiniIcons.tweak_lsp_kind) -- Lazily loads MiniIcons functionality
add_plugin("windwp/nvim-autopairs", "0.11.0") -- Autopairing for parenthesis etc.
add_plugin("folke/todo-comments.nvim", "v1.5.0", { opts = { signs = false } }) -- Adds support for TODO and other comments
add_plugin("neovim/nvim-lspconfig", "v2.5.0") -- Allows configuring LSPs
add_plugin("nvim-treesitter/nvim-treesitter", "v0.10.0", { -- Adds syntax highlighting
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"dockerfile",
			"editorconfig",
			"gitcommit",
			"gitignore",
			"json",
			"lua",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"python",
			"regex",
			"vim",
			"vimdoc",
		},
		auto_install = false, -- If true, automatically installs missing treesitter plugins if they are available
		highlight = {
			enable = true, -- Enables syntax highlighting
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby" } },
	},
})
add_plugin("saghen/blink.cmp", "v1.9.1", { -- Allows for autocompletion
	keymap = {
		preset = "default", -- By default, <Ctrl-n> for next item, <Ctrl-p> for previous item, <Ctrl-y> to confirm
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
	},
	sources = {
		default = { "lsp", "path" },
	},
	fuzzy = { implementation = "lua" }, -- Uses lua fuzzy matching
	signature = { enabled = true },
})
add_plugin("stevearc/conform.nvim", "v9.1.0", { -- Allows for autoformatting of code
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disable_filetypes = {}
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua", lsp_format = "fallback" },
			bash = { "shfmt", lsp_format = "fallback" },
			c = { "clang-format" },
			python = { "ruff_organize_imports", "ruff_format" },
		},
	},
})
add_plugin("folke/which-key.nvim", "v3.17.0", { -- Adds popup window showing keybinds
	opts = {
		delay = 0,
		icons = {
			mappings = vim.g.have_nerd_font,
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},
	},
})
add_plugin("lewis6991/gitsigns.nvim", "v2.0.0", { -- Adds signs tray to lines in git repo
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})
add_plugin("tpope/vim-fugitive", "v3.7")

-- ---------------------------------------------- --
-- Functions to allow cross-version compatibility --
-- ---------------------------------------------- --
local function lsp_setup(server, opts)
	if vim.fn.has("nvim-0.11") == 0 then
		require("lspconfig")[server].setup(opts)
		return
	end
	if not vim.tbl_isempty(opts) then
		vim.lsp.config(server, opts)
	end
	vim.lsp.enable(server)
end

local function client_supports_method(client, method, bufnr)
	if vim.fn.has("nvim-0.11") == 1 then
		return client:supports_method(method, bufnr)
	else
		return client.supports_method(method, { bufnr = bufnr })
	end
end

-- ----------------------- --
-- Leader Key and Keybinds --
-- ----------------------- --
vim.g.mapleader = vim.keycode("<Space>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat Buffer" })

-- ------------ --
-- LSP Keybinds --
-- ------------ --
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", { buffer = event.buf })

		vim.keymap.set(
			{ "n", "x" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			{ buffer = event.buf, desc = "LSP: [C]ode [A]ction" }
		)

		vim.keymap.set(
			{ "n" },
			"gO",
			vim.lsp.buf.document_symbol,
			{ buffer = event.buf, desc = "LSP: Open Document Symbols" }
		)

		vim.keymap.set({ "n" }, "grn", vim.lsp.buf.rename, { buffer = event.buf, desc = "LSP: [G]lobal [R]e[n]ame" })

		vim.keymap.set(
			{ "n" },
			"grr",
			vim.lsp.buf.references,
			{ buffer = event.buf, desc = "LSP: [G]oto [R]eferences" }
		)

		vim.keymap.set({ "n" }, "gri", vim.lsp.buf.implementation, {
			buffer = event.buf,
			desc = "LSP: [G]oto [I]mplementation",
		})

		vim.keymap.set(
			{ "n" },
			"grd",
			vim.lsp.buf.definition,
			{ buffer = event.buf, desc = "LSP: [G]oto [d]efinition" }
		)

		vim.keymap.set(
			{ "n" },
			"grD",
			vim.lsp.buf.declaration,
			{ buffer = event.buf, desc = "LSP: [G]oto [D]eclaration" }
		)

		vim.keymap.set(
			{ "n" },
			"grt",
			vim.lsp.buf.type_definition,
			{ buffer = event.buf, desc = "LSP: [G]oto [T]ype Definition" }
		)

		-- ----------------------- --
		-- Highlight word on hover --
		-- ----------------------- --
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if
			client
			and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
		then
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		-- ------------------- --
		-- Toggle inline hints --
		-- ------------------- --
		if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			vim.keymap.set("n", "<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, { buffer = event.buf, desc = "LSP: [T]oggle [H]ints" })
		end
	end,
})

-- ------------------- --
-- Auto Format on Save --
-- ------------------- --
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- ----------------- --
-- LSP Configuration --
-- ----------------- --
lsp_setup("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
					"require",
				},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

lsp_setup("bashls", {
	cmd = { "bashls", "start" },
	filetypes = { "bash", "sh" },
})

lsp_setup("basedpyright", {
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				useLibraryCodeForTypes = true,
				autoImportCompletions = true,
				autoSearchPaths = true,
				inlayHints = {
					variableTypes = true,
					callArgumentNames = true,
					functionReturnTypes = true,
				},
			},
		},
	},
})
