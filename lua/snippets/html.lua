local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("html", {
  s({ trig = "form~", priority = 1000 }, {
    t('<form method="'), i(1, ""), t('" action="'), i(2, ""), t('" name="'), i(3, ""), t('">'),
    t({ "", "  " }), i(4),
    t({ "", "</form>" }),
  }),
})
