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
        ]
      }

      {
        filters: ['setIsOnline']
        only: ['dashboard']
      }
    ]
