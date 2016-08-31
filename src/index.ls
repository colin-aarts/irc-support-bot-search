
#	irc-support-js-search
#	---------------------
#	Web search for irc-support-bot
#	This is an official plug-in
#
#	Provides one bot command: 'g'

'use strict'


util    = require 'util'
google  = require 'googleapis'
shorten = require 'goo.gl'


module.exports = ->

	this.register_special_command do
		name: 'g'
		description: 'Perform a web search using Google.'
		admin_only: false
		fn: (event, input_data, output_data) ~>

			opts = this.bot-options.plugin-options['irc-support-bot-search']
			query = input_data.args + ' -site:w3schools.com -site:tizag.com'

			more-results-url <~ (_) ~>
				full = """https://google.com/search?q=#query"""
				err, result <~ shorten full, opts.api-key
				short = result.id unless err
				_ short || full

			unless opts
				console.error 'No options specified for « irc-support-bot-search ». Missing API key.'
				return

			err, result <~ google.customsearch 'v1' .cse.list do
				auth: opts.api-key
				cx: opts.engine-id
				q: query

			if err
				message = 'Oops, something went wrong!'
			else if not result.items.0
				message = "No results for query '#{input_data.args}'"
			else
				message = """Google says "#{result.items.0.title}" • #{result.items.0.link} • More results: #more-results-url"""

			this.send output_data.method, output_data.recipient, message
