document.addEventListener("turbo:load", function() {
  // アカウントのボタンをクリックするとドロップダウンメニューが表示される
  let account = document.querySelector("#account");
  if (account) {
    account.addEventListener("click", function(event) {
      event.preventDefault();
      let menu = document.querySelector("#dropdown-menu");
      menu.classList.toggle("active");
    });
  }

  // アカウントのボタンをクリックするとドロップダウンメニューが表示される（モバイル表示版）
  let mobileaccount = document.querySelector("#mobile-account");
  if (mobileaccount) {
    mobileaccount.addEventListener("click", function(event) {
      event.preventDefault();
      let mobilemenu = document.querySelector("#mobile-dropdown-menu");
      mobilemenu.classList.toggle("active");
    });
  }

  // ハンバーガーボタンをクリックするとドロップダウンメニューが表示される
  let hamburger = document.querySelector("#hamburger");
  if (hamburger){
    hamburger.addEventListener("click", function(event) {
      event.preventDefault();
      let menu = document.querySelector("#navbar-menu");
      menu.classList.toggle("collapse");
    });
  }

  // プラスボタンを押すとコンテンツが表示される
  let buttons = document.querySelectorAll('.caption__button');
  buttons.forEach(button => {
    button.addEventListener('click', function() {
      // クリックされたボタンにclickedクラスがあるか確認
      if (this.classList.contains('clicked')) {
        // clickedクラスがあれば削除
        this.classList.remove('clicked');
      } else {
        // clickedクラスがなければ追加
        this.classList.add('clicked');
      }
      let captionAttr = button.getAttribute('caption-attr');
      
      if (captionAttr=='about__button') {
        let aboutButton = document.querySelector(".about__explanation");
        aboutButton.classList.toggle("active");
      }
      if (captionAttr=='functions1__button') {
        let functionsButton = document.querySelector(".functions1__explanation");
        functionsButton.classList.toggle("active");
      }
      if (captionAttr=='functions2__button') {
        let functionsButton = document.querySelector(".functions2__explanation");
        functionsButton.classList.toggle("active");
      }
      if (captionAttr=='functions3__button') {
        let functionsButton = document.querySelector(".functions3__explanation");
        functionsButton.classList.toggle("active");
      }
    });
  });

  // モーダルウィンドウの表示と非表示
  let modalButton = document.querySelectorAll('.js-modal-open');
  let modalClose = document.querySelectorAll('.js-close-button');　// xボタンのjs-close-buttonを取得し変数に格納
  
  modalButton.forEach(button => {
    button.addEventListener('click', () => {
      // クリックされたボタンからモーダルのIDを取得し、IDから要素を取得
      let modalId = button.getAttribute('data-modal-id');
      console.log(modalId);
      let modal = document.getElementById(modalId);
      console.log(modal);

      // クリックされたボタンからdrink_dayのデータを取得
      let drinkDay = button.getAttribute('data-drink-day');

      // recordValueの値をif文の条件式に使用するために、JSON型に変形
      var records = document.getElementById(`records-${drinkDay}`);
      var recordsValue = JSON.parse(records.getAttribute('data-records-value'));

      // クリックした日付にレコードがあれば編集画面、なければ登録画面を開く
      if (!(Array.isArray(recordsValue) && recordsValue.length === 0)) {
        // サーバーにリクエストを送るためのURL
        const url = `/records/edit_by_day?drink_day=${drinkDay}`;

        // Fetch APIを使用して、非同期にデータを取得する
        fetch(url,{method: 'GET',headers: {'X-Requested-With': 'XMLHttpRequest'}})
          .then(response => response.text())
          .then(html => {
            // 取得したHTMLをモーダル内に挿入
            modal.querySelector('.modal__content').innerHTML = html;

            // レコード編集用のモーダルウィンドウを開く
            modal.classList.add('is-open');
            document.body.style.overflow = 'hidden'; // 背景のスクロールを無効化
          })
            .catch(error => {
              console.error('Error fetching modal content:', error);
            });
      } else {
        // レコード登録用のモーダルウィンドウを開く
        modal.classList.add('is-open');
        document.body.style.overflow = 'hidden'; // 背景のスクロールを無効化
      }
    });
  });

  // バツボタンが押されたらモーダルウィンドウを閉じる
  modalClose.forEach(button => {
    button.addEventListener('click', () => {
      let modal = button.closest('.js-modal');
      modal.classList.remove('is-open'); 
      document.body.style.overflow = ''; // 背景のスクロールを再有効化
    });
  });  
});
  