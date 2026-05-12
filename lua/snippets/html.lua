local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep


ls.add_snippets("html", {
  s({ trig = "form~", priority = 1000 }, {
    t('<form method="'), i(1, ""), t('" action="'), i(2, ""), t('" name="'), i(3, ""), t('">'),
    t({ "", "  " }), i(4),
    t({ "", "</form>" }),
  }),
  s({ trig = "label~" }, {
    t("<label>"),
    t({ "", "  " }), i(1, "Label text"),
    t({ "", "  <input type=\"" }), i(2, "text"), t('" name="'), i(3, ""), t('">'),
    t({ "", "</label>" }),
  }),
  s({ trig = "field~" }, {
    t('<div>'),
    t({ "", '  <label for="' }), i(1, "name"), t('">'), i(2, "Label text"), t('</label>'),
    t({ "", '  <input type="' }), i(3, "text"), t('" id="'), rep(1), t('" name="'), i(4, ""), t('" />'),
    t({ "", '</div>' }),
  }),
})
