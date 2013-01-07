module.exports =
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
