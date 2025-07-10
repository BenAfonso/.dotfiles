-- https://github.com/graphql/graphiql/tree/main/packages/graphql-language-service-cli

return {
  cmd          = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes    = { 'graphql', 'typescriptreact', 'javascriptreact' },
  root_markers = {
    '.graphqlrc*',
    '.graphql.config.*',
    'graphql.config.*'
  },
}
