local tfdoc = require("telescope._extensions.tfdoc.builtin")

return require("telescope").register_extension({
	exports = {
		tfdoc = tfdoc.exec,
	},
})
