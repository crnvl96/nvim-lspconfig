---@brief
---
--- https://github.com/mickael-menu/zk
---
--- A plain text note-taking assistant

local function find_zk_root(startpath)
  for dir in vim.fs.parents(startpath) do
    if vim.fn.isdirectory(vim.fs.joinpath(dir, '.zk')) == 1 then
      return dir
    end
  end
end

return {
  cmd = { 'zk', 'lsp' },
  filetypes = { 'markdown' },
  root_markers = { '.zk' },
  on_attach = function(_, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'LspZkIndex', function()
      vim.lsp.buf.execute_command {
        command = 'zk.index',
        arguments = { vim.api.nvim_buf_get_name(bufnr) },
      }
    end, {
      desc = 'ZkIndex',
    })

    vim.api.nvim_buf_create_user_command(bufnr, 'LspZkList', function()
      local bufpath = vim.api.nvim_buf_get_name(bufnr)
      local root = find_zk_root(bufpath)

      vim.lsp.buf_request(bufnr, 'workspace/executeCommand', {
        command = 'zk.list',
        arguments = { root, { select = { 'path' } } },
      }, function(_, result, _, _)
        if not result then
          return
        end
        local paths = vim.tbl_map(function(item)
          return item.path
        end, result)
        vim.ui.select(paths, {}, function(choice)
          vim.cmd('edit ' .. choice)
        end)
      end)
    end, {
      desc = 'ZkList',
    })

    vim.api.nvim_buf_create_user_command(bufnr, 'LspZkNew', function(...)
      vim.lsp.buf_request(bufnr, 'workspace/executeCommand', {
        command = 'zk.new',
        arguments = {
          vim.api.nvim_buf_get_name(bufnr),
          ...,
        },
      }, function(_, result, _, _)
        if not (result and result.path) then
          return
        end
        vim.cmd('edit ' .. result.path)
      end)
    end, {
      description = 'ZkNew',
    })
  end,
}
