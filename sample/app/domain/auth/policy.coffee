module.exports =
  applyTo: /^[^\/]+$/ # only top level
  filterPrefix: 'filters'
  rules:
    [
      {
        filters: ['isLoggedIn']
        except: [
          'getRole'
          'login'
          'invalidReturn'
          'sendEmail'
          'relayContext'
        ]
      }

      {
        filters: ['setIsOnline']
        only: ['dashboard']
      }
    ]
