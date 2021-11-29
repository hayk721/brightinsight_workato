{
  title: 'JamaSoftware user provisioning',

  connection: {
    fields: [
      {
        name: 'client_id',
        optional: false,
      },
      {
        name: 'client_secret',
        control_type: 'password',
        optional: false,
      },
      {
        name: 'subdomain',
        control_type: 'subdomain',
        url: '.jamacloud.com',
        optional: false
      }
    ],

    authorization: {
      type: 'custom_auth', #Set to custom_auth

      acquire: lambda do |connection|
        hash = "#{connection['client_id']}:#{connection['client_secret']}"
                 .base64.gsub("\n", '')
        # Token URL
        response = post("https://#{connection['subdomain']}.jamacloud.com/rest/oauth/token")
                     .payload(grant_type: 'client_credentials')
                     .headers(Authorization: "Basic #{hash}")
                     .request_format_www_form_urlencoded

        {
          access_token: response['access_token'],
        }
      end,

      refresh_on: [401, 403],

      refresh: lambda do |_connection|
        hash = "#{_connection['client_id']}:#{_connection['client_secret']}"
                 .base64.gsub("\n", '')
        # Token URL
        response = post("https://#{_connection['subdomain']}.jamacloud.com/rest/oauth/token")
                     .payload(grant_type: 'client_credentials')
                     .headers(Authorization: "Basic #{hash}")
                     .request_format_www_form_urlencoded

        {
          access_token: response['access_token'],
        }
      end,

      apply: lambda do |_connection|
        if _connection['access_token']
          headers("Authorization": "Bearer #{_connection["access_token"]}")
        end

      end
    },

    base_uri: lambda do |connection|
      "https://#{connection['subdomain']}.jamacloud.com/rest"
    end

  },

  test: lambda do |connection|
    get('')
  end,

  actions: {
    get_user: {
      title: 'Get User',
      subtitle: 'Get the user with the specified ID',
      description: "Get <span class='provider'>user</span> " \
        "from the <span class='provider'>specified ID</span>",
      help: 'This action retrieve user with the specified ID',
      input_fields: lambda do |object_definitions|
        object_definitions['user_query']
      end,
      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        get("/rest/v1/users/#{_input['user_id']}").params(include: _input['include'])
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['user_output']
      end,
      sample_output: lambda do |_connection, _input|
        get("/rest/v1/users/#{_input['user_id']}").params(include: _input['include'])
      end
    },
    get_user_current: {
      title: 'Get Current User',
      subtitle: 'Get the current user',
      description: "Get <span class='provider'>current</span> " \
        "<span class='provider'>user</span>",
      help: 'Gets the current user',
      input_fields: lambda do |object_definitions|
        object_definitions['user_query_current']
      end,
      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        get('/rest/v1/users/current').params(include: _input['include'])
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['user_output']
      end,
      sample_output: lambda do |_connection, _input|
        get('/rest/v1/users/current').params(include: _input['include'])
      end
    },
    get_user_favorite_filters: {
      title: 'Get favorite filters',
      subtitle: "Gets the current user's favorite filters",
      description: "Get <span class='provider'>current</span> " \
        "user's <span class='provider'>favorite filters</span>",
      help: "Gets the current user's favorite filters",

      input_fields: lambda do |object_definitions|
        object_definitions['user_query_favorite_filters']
      end,
      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        get('/rest/v1/users/current/favoritefilters').params(startAt: _input['startAt'], maxResults: _input['maxResults'], include: _input['include'])
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['user_favorite_filters_output']
      end,
      sample_output: lambda do |_connection, _input|
        get('/rest/v1/users/current/favoritefilters').params(startAt: _input['startAt'], maxResults: _input['maxResults'], include: _input['include'])
      end
    },
    get_users: {
      title: 'Get Users',
      subtitle: 'Get all user groups',
      description: "Get <span class='provider'>all</span> " \
        "<span class='provider'>users</span>",
      help: 'Get all user groups',
      input_fields: lambda do |object_definitions|
        object_definitions['users_query']
      end,
      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        get('/rest/v1/users').params(project: _input['project'], startAt: _input['startAt'], maxResults: _input['maxResults'], include: _input['include'])
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['users_output']
      end,
      sample_output: lambda do |_connection, _input|
        get('/rest/v1/users').params(project: _input['project'], startAt: _input['startAt'], maxResults: _input['maxResults'], include: _input['include'])
      end
    },
    create_user: {

      title: 'Create User',
      subtitle: 'Create a user from a directory by userId',
      description: "Create <span class='provider'>user</span> " \
        "from the <span class='provider'>specified directory</span>",
      help: "Creates a user's information in a directory by userId via user attributes. User information is replaced attribute-by-attribute, with the exception of immutable and read-only attributes. Existing values of unspecified attributes are cleaned.",

      input_fields: lambda do |object_definitions|
        object_definitions['user_create_update'].ignored('id')
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        post('/rest/v1/users', _input)
          .after_error_response(/.*/) do |_, body, _, message|
          error("#{message}: #{body}")
        end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['user_create_output']
      end,

      sample_output: lambda do |_connection, _input|
        get('/rest/v1/users/current')
      end
    },
    update_user: {

      title: 'Update User',
      subtitle: 'Update the user group with the specified ID',
      description: "Update <span class='provider'>user</span> " \
        "from the <span class='provider'>specified directory</span>",
      help: 'Update the user group with the specified ID',

      input_fields: lambda do |object_definitions|
        object_definitions['user_create_update']
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        put("/rest/v1/users/#{_input['id']}", _input.except('id'))
          .after_error_response(/.*/) do |_, body, _, message|
          error("#{message}: #{body}")
        end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['user_update_output']
      end,

      sample_output: lambda do |_connection, _input|
        get('/rest/v1/users/current')
      end
    },
    update_user_status: {

      title: 'Update User active status',
      subtitle: 'Update the active status for the user with the specified ID',
      description: "Update the <span class='provider'>active status</span> for the user" \
        "with the <span class='provider'>specified ID</span>",
      help: 'Update the active status for the user with the specified ID',

      input_fields: lambda do |object_definitions|
        [
          { name: 'id', type: 'integer', optional: false },
          call('toggle_checkbox', 'active')
        ]
      end,

      execute: lambda do |_connection, _input, _input_schema, _output_schema|
        put("/rest/v1/users/#{_input['id']}/active", _input.except('id'))
          .after_error_response(/.*/) do |_, body, _, message|
          error("#{message}: #{body}")
        end
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['user_update_output']
      end,

      sample_output: lambda do |_connection, _input|
        get('/rest/v1/users/current')
      end
    }
  },

  triggers: {

  },

  methods: {
    toggle_checkbox: lambda do |input|
      {
        name: input,
        type: 'boolean',
        control_type: 'checkbox',
        convert_input: 'boolean_conversion',
        toggle_hint: 'Select from list',
        toggle_field: {
          name: input,
          type: 'string', control_type: 'text', optional: true,
          toggle_hint: 'Use custom value',
          hint: 'Allowed values are: <b>true</b>, <b>false</b>'
        }

      }
    end,
  },

  object_definitions: {
    user_output: {
      fields: lambda do |_connection, _config_fields|
        [

          { name: 'data', type: 'object', properties: [
            { name: 'id', type: 'integer' },
            { name: 'username' },
            { name: 'firstname' },
            { name: 'lastname' },
            { name: 'email', control_type: 'email' },
            { name: 'phone', control_type: 'phone' },
            { name: 'title' },
            { name: 'location' },
            { name: 'licenseType' },
            { name: 'avatarUrl', type: 'string', control_type: 'url' },
            { name: 'active', type: 'boolean' },
            { name: 'authenticationType', type: 'integer' }
          ] },
          { name: 'meta', type: 'array', of: 'object', properties: [
            { name: 'status' },
            { name: 'timestamp', type: 'timestamp' }
          ] },
          { name: 'links', type: 'object', hint: 'Links to include as full objects in the linked map' },
          { name: 'linked', type: 'object', hint: 'Links to include as full objects in the linked map' }

        ]
      end
    },
    users_output: {
      fields: lambda do |_connection, _config_fields|
        [

          { name: 'data', type: 'array', of: 'object', properties: [
            { name: 'id', type: 'integer' },
            { name: 'username' },
            { name: 'firstname' },
            { name: 'lastname' },
            { name: 'email', control_type: 'email' },
            { name: 'phone', control_type: 'phone' },
            { name: 'title' },
            { name: 'location' },
            { name: 'licenseType' },
            { name: 'avatarUrl', type: 'string', control_type: 'url' },
            { name: 'active', type: 'boolean' },
            { name: 'authenticationType', type: 'integer' }
          ] },
          { name: 'meta', type: 'object', properties: [
            { name: 'status' },
            { name: 'timestamp', type: 'timestamp' },
            { name: 'pageInfo', type: 'object', properties: [
              { name: 'startIndex', type: 'integer' },
              { name: 'resultCount', type: 'integer' },
              { name: 'totalResults', type: 'integer' }
            ] }] },
          { name: 'links', type: 'object', hint: 'Links to include as full objects in the linked map' },
          { name: 'linked', type: 'object', hint: 'Links to include as full objects in the linked map' }

        ]
      end
    },
    user_favorite_filters_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'data',
            type: 'array',
            of: 'object',
            properties: [
              {
                name: 'specifiedProject',
                type: 'integer'
              },
              {
                name: 'public',
                type: 'boolean'
              },
              {
                name: 'author',
                type: 'integer'
              },
              {
                name: 'name',
                type: 'string'
              },
              {
                name: 'id',
                type: 'integer'
              },
              {
                name: 'projectScope',
                type: 'string'
              },
              {
                name: 'filterQuery',
                type: 'object',
                properties: [
                  {
                    name: 'orderRules',
                    type: 'array',
                    of: 'object',
                    properties: [
                      {
                        name: 'field',
                        type: 'object',
                        properties: [
                          {
                            name: 'display',
                            type: 'string'
                          },
                          {
                            name: 'name',
                            type: 'string'
                          },
                          {
                            name: 'id',
                            type: 'integer'
                          },
                          {
                            name: 'fieldDataType',
                            type: 'string'
                          }
                        ]
                      },
                      {
                        name: 'direction',
                        type: 'string'
                      }
                    ]
                  },
                  {
                    name: 'name',
                    type: 'string'
                  },
                  {
                    name: 'rule',
                    type: 'object',
                    properties: [
                      {
                        name: 'itemType',
                        type: 'integer'
                      },
                      {
                        name: 'field',
                        type: 'object',
                        properties: [
                          {
                            name: 'display',
                            type: 'string'
                          },
                          {
                            name: 'name',
                            type: 'string'
                          },
                          {
                            name: 'id',
                            type: 'integer'
                          },
                          {
                            name: 'fieldDataType',
                            type: 'string'
                          }
                        ]
                      },
                      {
                        name: 'values',
                        type: 'array',
                        of: 'string'
                      },
                      {
                        name: 'rules',
                        type: 'array',
                        of: 'object',
                        properties: [
                          {
                            name: 'itemType',
                            type: 'integer'
                          },
                          {
                            name: 'field',
                            type: 'object',
                            properties: [
                              {
                                name: 'display',
                                type: 'string'
                              },
                              {
                                name: 'name',
                                type: 'string'
                              },
                              {
                                name: 'id',
                                type: 'integer'
                              },
                              {
                                name: 'fieldDataType',
                                type: 'string'
                              }
                            ]
                          },
                          {
                            name: 'values',
                            type: 'array',
                            of: 'string'
                          },
                          {
                            name: 'rules',
                            type: 'array'
                          },
                          {
                            name: 'operator',
                            type: 'string',
                            of: 'object'
                          }
                        ]
                      },
                      {
                        name: 'operator',
                        type: 'string'
                      }
                    ]
                  }
                ]
              }
            ]
          },
          {
            name: 'meta',
            type: 'object',
            properties: [
              {
                name: 'pageInfo',
                type: 'object',
                properties: [
                  {
                    name: 'startIndex',
                    type: 'integer'
                  },
                  {
                    name: 'resultCount',
                    type: 'integer'
                  },
                  {
                    name: 'totalResults',
                    type: 'integer'
                  }
                ]
              },
              {
                name: 'status',
                type: 'string'
              },
              {
                name: 'timestamp',
                type: 'string'
              }
            ]
          },
          {
            name: 'links',
            type: 'object',
            properties: [
              {
                name: 'key',
                type: 'object',
                properties: [
                  {
                    name: 'href',
                    type: 'string'
                  },
                  {
                    name: 'type',
                    type: 'string'
                  }
                ]
              }
            ]
          },
          {
            name: 'linked',
            type: 'object',
            properties: [
              {
                name: 'key',
                type: 'object',
                properties: [
                  {
                    name: 'key',
                    type: 'string'
                  }
                ]
              }
            ]
          }
        ]
      end
    },
    user_query: {
      fields: lambda do |_connection, _config_fields|
        [

          { name: 'user_id', type: 'integer', optional: false },
          { name: 'include', type: 'array', of: 'object', properties: [
            { name: 'key', type: 'array', of: 'object', properties: [
              { name: 'key' }
            ] }
          ],
            hint: 'Links to include as full objects in the linked map'
          }
        ]
      end
    },
    user_query_current: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'include', type: 'array', of: 'object', properties: [
            { name: 'key', type: 'array', of: 'object', properties: [
              { name: 'key' }
            ] }
          ],
            hint: 'Links to include as full objects in the linked map'
          }
        ]
      end
    },
    user_query_favorite_filters: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'startAt', type: 'integer', sticky: true },
          { name: 'maxResults', type: 'integer', sticky: true, hint: 'If not set, this defaults to 20. This cannot be larger than 50' },
          { name: 'include', type: 'array', of: 'object', properties: [
            { name: 'key', type: 'array', of: 'object', properties: [
              { name: 'key' }
            ] }
          ],
            hint: 'Links to include as full objects in the linked map'
          }
        ]
      end
    },
    users_query: {
      fields: lambda do |_connection, _config_fields|
        [

          { name: 'project', type: 'integer', sticky: true },
          { name: 'startAt', type: 'integer', sticky: true },
          { name: 'maxResults', type: 'integer', sticky: true, hint: 'If not set, this defaults to 20. This cannot be larger than 50' },
          { name: 'include', type: 'array', of: 'object', properties: [
            { name: 'key', type: 'array', of: 'object', properties: [
              { name: 'key' }
            ] }
          ],
            hint: 'Links to include as full objects in the linked map'
          }
        ]
      end
    },
    user_create_update: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'id', type: 'integer', optional: false },
          { name: 'username', optional: false },
          { name: 'firstName', optional: false },
          { name: 'lastName', optional: false },
          { name: 'email', optional: false, control_type: 'email' },
          { name: 'password', optional: false, control_type: 'password' },
          { name: 'phone', control_type: 'phone' },
          { name: 'title' },
          { name: 'location' },
          { name: 'licenseType', optional: false },
          { name: 'avatarUrl', type: 'string', control_type: 'url' },
          { name: 'active', type: 'boolean' },
          { name: 'authenticationType', type: 'integer' }
        ]
      end
    },
    user_create_output: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'meta', type: 'object', properties: [
            { name: 'status', type: 'string' },
            { name: 'timestamp', type: 'timestamp' },
            { name: 'location', type: 'string' },
            { name: 'id', type: 'integer' }
          ] }
        ]
      end
    },
    user_update_output: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'meta', type: 'object', properties: [
            { name: 'status', type: 'string' },
            { name: 'timestamp', type: 'timestamp' }
          ] }
        ]
      end
    },
  },

  pick_lists: {

  }
}
