local M = {}

M.find_files = function(options)
  options.attach_mappings = function(prompt_bufnr, map)
    local create_new_file = require("ben.telescope.create_new_file").create_new_file(options, prompt_bufnr)
    local delete_file = require("ben.telescope.delete_file").delete_file(options, prompt_bufnr)

    map("i", "<C-e>", create_new_file)
    map("n", "<C-e>", create_new_file)

    map("i", "<C-d>", delete_file)
    map("n", "<C-d>", delete_file)
    map("n", "dd", delete_file)

    return true
  end

  require("telescope.builtin").find_files(options)
end

return M
