component Layout {
  property children : Array(Html) = []

  style base {
    flex-direction: column;
    min-height: 100vh;
    display: flex;
  }

  style content {
    flex: 1;
  }

  fun render : Html {
    <div::base>
      <Header/>

      <div::content>
        <{ children }>
      </div>

      <Footer/>
    </div>
  }
}

component Logo {
  style base {
    fill: currentColor;
  }

  fun render : Html {
    <svg::base
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      height="24"
      width="24">

      <path
        d={
          "M4 4v20h20v-20h-20zm18 18h-16v-13h16v13zm-3-3h-10v-1h10v" \
          "1zm0-3h-10v-1h10v1zm0-3h-10v-1h10v1zm2-11h-19v19h-2v-21h" \
          "21v2z"
        }/>

    </svg>
  }
}

component Main {
  connect Application exposing { page }

  get content : Html {
    case (page) {
      Page::Home => <Pages.Home/>
      Page::Article => <Pages.Article/>
      Page::Login => <Pages.Login/>
    }
  }

  fun render : Html {
    <Layout>
      <{ content }>
    </Layout>
  }
}

store Application {
  state page : Page = Page::Initial

  fun initializeWithPage (page : Page) : Void {
    Array.do([
      setPage(page),
      initialize()
    ])
  }

  fun initialize : Void {
    case (Stores.User.status) {
      Auth.Status::Initial => Stores.User.getCurrentUser()
      => void
    }
  }

  fun setPage (page : Page) : Void {
    next { page = page }
  }
}

enum Page {
  Login
  Initial
  Home
  Article
}

routes {
  / {
    Array.do(
      [
        Application.initializeWithPage(Page::Home),
        Stores.Tags.load(),
        do {
          params =
            Stores.Articles.params

          Stores.Articles.load({ params | tag = "" })
        }
      ])
  }

  /articles?tag=:tag (tag : String) {
    Array.do(
      [
        Application.initializeWithPage(Page::Home),
        Stores.Tags.load(),
        do {
          params =
            Stores.Articles.params

          Stores.Articles.load({ params | tag = tag })
        }
      ])
  }

  /login {
    do {
      Application.initialize()

      case (Stores.User.status) {
        Auth.Status::Authenticated => Window.navigate("/")
        => Application.setPage(Page::Login)
      }
    }
  }

  /logout {
    do {
      Application.initialize()

      case (Stores.User.status) {
        Auth.Status::Authenticated =>
          do {
            Stores.User.logout()
            Window.navigate("/")
          }

        => Window.navigate("/")
      }
    }
  }

  /article/:slug (slug : String) {
    Array.do(
      [
        Application.initializeWithPage(Page::Article),
        Stores.Article.load(slug),
        do {
          Stores.Comments.reset()
          Stores.Comments.load(slug)
        }
      ])
  }

  * {
    Application.initialize()
  }
}
