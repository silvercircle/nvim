------------------------------ edit the following to reflect your configuration
local workspace_dir = "/home/alex/.cache/jdtls_workspace/"
local jdtls_install_dir = "/home/alex/.local/share/nvim/mason/packages/jdtls/"
local equinox_version = "1.6.600.v20231012-1237"
local java_executable = "/usr/bin/java"
local use_lombok = true
------------------------------ stop edit ---------------------------

local lsputil = require("lspconfig.util")
local md5 = require("local_utils.md5")
local hash
local project_name = "tmp"
local debug = true

-- this tries to find a project root directory using common patterns. It searches
-- for maven or gradle configuration files, eclipse or IDEA configurations and if all
-- fails, a .git root.
-- TODO: this is probably incomplete and sub-optimal. improvements possible

-- try two levels of patterns. Safe are considered gradle and maven project files
--
local root_patterns = {
  safe =  { "pom.xml", "settings.gradle", ".settings", ".gradle" },
  guess = { ".project", "nbproject", ".git", ".idea" }
}

local function find_root(file)
  local try = lsputil.root_pattern(root_patterns.safe)(file)
  if try == nil or #try < 2 then
    try = lsputil.root_pattern(root_patterns.guess)(file)
  end
  return try
end

local project_root = find_root(vim.fn.expand("%:p"))

-- the project name is basically the name of the root directory of the project
-- since the jdtls workspace folder must be unique on a "per project" basis,
-- in order to support multiple project with the same base folder name, we just
-- hash the full path.
if vim.bo.buftype == "nofile" or project_root == nil or #project_root < 2 then
  if debug then vim.notify("No project root") end
elseif project_root ~= nil and #project_root > 1 then
  hash = md5.new()
  hash:update(string.lower(project_root))
  project_name = md5.tohex(hash:finish())
else
end

workspace_dir = workspace_dir .. project_name

if debug then vim.notify("Project name is: " .. project_name) end

-- configure special buffers. These are opened when using a jdt:// link to decompile
-- classes.
if vim.bo.buftype == "nofile" and vim.startswith(vim.fn.expand("%"), "jdt://") then
  vim.cmd("setlocal number | setlocal signcolumn=yes:3 | setlocal foldcolumn=1 | setlocal nospell")
  __Globals.set_statuscol("normal")
end
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {

    java_executable, -- or '/:path/to/java17_or_newer/bin/java'
    -- depends on if `java` is in your $PATH env variable and if it points to the right version.

    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx768m",
    "-XX:-TieredCompilation",
    "-XX:+UseStringDeduplication",
    "-XX:+UseCompressedOops",

    "-XX:+UseParallelGC",
    "-XX:MaxGCPauseMillis=200",
    "-XX:+ScavengeBeforeFullGC",
    "-XX:MaxHeapFreeRatio=85",
    "-XX:ConcGCThreads=2",
    "-XX:ParallelGCThreads=2",

    use_lombok and "-javaagent:" .. jdtls_install_dir .. "lombok.jar" or "",
    use_lombok and "-Xbootclasspath/a:" .. jdtls_install_dir .. "lombok.jar" or "",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",

    "-jar", jdtls_install_dir .. "plugins/org.eclipse.equinox.launcher_" .. equinox_version .. ".jar",

    "-configuration", jdtls_install_dir .. "config_linux",

    "-data", workspace_dir
  },

  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", ".gradle" }),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      -- configure the code formatter with a formatting style
      -- this uses a slightly modified version of Google's Java Coding Style
      -- you can use anything here
      -- full documentation on the formatting options available here.
      -- https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.jdt.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fjdt%2Fcore%2Fformatter%2FDefaultCodeFormatterConstants.html
      format = {
        settings = {
          url = vim.fn.stdpath("config") .. "/addons/jdtls_format.xml",
          -- basically only needed when the xml contains multiple styles.
          -- you could insert some logic here to allow per project formatting styles
          profile = "GoogleStyle"
        }
      }
    }
  },
  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {}
  },
  on_attach = function() vim.lsp.codelens.refresh() end
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
