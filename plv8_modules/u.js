(function(){
  var unicodeNonLetters, merge, title2slug, topForums, subForums, topPosts, subPosts, subPostsTree, postsTree, decorateMenu, decorateForum, doc, putDoc, forumTree, forumsTree, uriForForum, uriForPost, menu, homepageForums, forums, topThreads, out$ = typeof exports != 'undefined' && exports || this, slice$ = [].slice;
  out$.unicodeNonLetters = unicodeNonLetters = /[^A-ZÀ-ÖØ-ÞĀĂĄĆĈĊČĎĐĒĔĖĘĚĜĞĠĢĤĦĨĪĬĮİĲĴĶĹĻĽĿŁŃŅŇŊŌŎŐŒŔŖŘŚŜŞŠŢŤŦŨŪŬŮŰŲŴŶŸŹŻŽƁƂƄƆƇƉ-ƋƎ-ƑƓƔƖ-ƘƜƝƟƠƢƤƦƧƩƬƮƯƱ-ƳƵƷƸƼǄǇǊǍǏǑǓǕǗǙǛǞǠǢǤǦǨǪǬǮǱǴǶ-ǸǺǼǾȀȂȄȆȈȊȌȎȐȒȔȖȘȚȜȞȠȢȤȦȨȪȬȮȰȲȺȻȽȾɁɃ-ɆɈɊɌɎΆΈ-ΊΌΎΏΑ-ΡΣ-Ϋϒ-ϔϘϚϜϞϠϢϤϦϨϪϬϮϴϷϹϺϽ-ЯѠѢѤѦѨѪѬѮѰѲѴѶѸѺѼѾҀҊҌҎҐҒҔҖҘҚҜҞҠҢҤҦҨҪҬҮҰҲҴҶҸҺҼҾӀӁӃӅӇӉӋӍӐӒӔӖӘӚӜӞӠӢӤӦӨӪӬӮӰӲӴӶӸӺӼӾԀԂԄԆԈԊԌԎԐԒԱ-ՖႠ-ჅḀḂḄḆḈḊḌḎḐḒḔḖḘḚḜḞḠḢḤḦḨḪḬḮḰḲḴḶḸḺḼḾṀṂṄṆṈṊṌṎṐṒṔṖṘṚṜṞṠṢṤṦṨṪṬṮṰṲṴṶṸṺṼṾẀẂẄẆẈẊẌẎẐẒẔẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼẾỀỂỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪỬỮỰỲỴỶỸἈ-ἏἘ-ἝἨ-ἯἸ-ἿὈ-ὍὙὛὝὟὨ-ὯᾸ-ΆῈ-ΉῘ-ΊῨ-ῬῸ-Ώℂℇℋ-ℍℐ-ℒℕℙ-ℝℤΩℨK-ℭℰ-ℳℾℿⅅↃⰀ-ⰮⱠⱢ-ⱤⱧⱩⱫⱵⲀⲂⲄⲆⲈⲊⲌⲎⲐⲒⲔⲖⲘⲚⲜⲞⲠⲢⲤⲦⲨⲪⲬⲮⲰⲲⲴⲶⲸⲺⲼⲾⳀⳂⳄⳆⳈⳊⳌⳎⳐⳒⳔⳖⳘⳚⳜⳞⳠⳢＡ-Ｚǅǈǋǲᾈ-ᾏᾘ-ᾟᾨ-ᾯᾼῌῼƻǀ-ǃʔא-תװ-ײء-غف-يٮٯٱ-ۓەۮۯۺ-ۼۿܐܒ-ܯݍ-ݭހ-ޥޱߊ-ߪऄ-हऽॐक़-ॡॻ-ॿঅ-ঌএঐও-নপ-রলশ-হঽৎড়ঢ়য়-ৡৰৱਅ-ਊਏਐਓ-ਨਪ-ਰਲਲ਼ਵਸ਼ਸਹਖ਼-ੜਫ਼ੲ-ੴઅ-ઍએ-ઑઓ-નપ-રલળવ-હઽૐૠૡଅ-ଌଏଐଓ-ନପ-ରଲଳଵ-ହଽଡ଼ଢ଼ୟ-ୡୱஃஅ-ஊஎ-ஐஒ-கஙசஜஞடணதந-பம-ஹఅ-ఌఎ-ఐఒ-నప-ళవ-హౠౡಅ-ಌಎ-ಐಒ-ನಪ-ಳವ-ಹಽೞೠೡഅ-ഌഎ-ഐഒ-നപ-ഹൠൡඅ-ඖක-නඳ-රලව-ෆก-ะาำเ-ๅກຂຄງຈຊຍດ-ທນ-ຟມ-ຣລວສຫອ-ະາຳຽເ-ໄໜໝༀཀ-ཇཉ-ཪྈ-ྋက-အဣ-ဧဩဪၐ-ၕა-ჺᄀ-ᅙᅟ-ᆢᆨ-ᇹሀ-ቈቊ-ቍቐ-ቖቘቚ-ቝበ-ኈኊ-ኍነ-ኰኲ-ኵኸ-ኾዀዂ-ዅወ-ዖዘ-ጐጒ-ጕጘ-ፚᎀ-ᎏᎠ-Ᏼᐁ-ᙬᙯ-ᙶᚁ-ᚚᚠ-ᛪᜀ-ᜌᜎ-ᜑᜠ-ᜱᝀ-ᝑᝠ-ᝬᝮ-ᝰក-ឳៜᠠ-ᡂᡄ-ᡷᢀ-ᢨᤀ-ᤜᥐ-ᥭᥰ-ᥴᦀ-ᦩᧁ-ᧇᨀ-ᨖᬅ-ᬳᭅ-ᭋℵ-ℸⴰ-ⵥⶀ-ⶖⶠ-ⶦⶨ-ⶮⶰ-ⶶⶸ-ⶾⷀ-ⷆⷈ-ⷎⷐ-ⷖⷘ-ⷞ〆〼ぁ-ゖゟァ-ヺヿㄅ-ㄬㄱ-ㆎㆠ-ㆷㇰ-ㇿ㐀䶵一龻ꀀ-ꀔꀖ-ꒌꠀꠁꠃ-ꠅꠇ-ꠊꠌ-ꠢꡀ-ꡳ가힣豈-鶴侮-頻並-龎יִײַ-ﬨשׁ-זּטּ-לּמּנּסּףּפּצּ-ﮱﯓ-ﴽﵐ-ﶏﶒ-ﷇﷰ-ﷻﹰ-ﹴﹶ-ﻼｦ-ｯｱ-ﾝﾠ-ﾾￂ-ￇￊ-ￏￒ-ￗￚ-ￜʰ-ˁˆ-ˑˠ-ˤˮͺՙـۥۦߴߵߺๆໆჼៗᡃᴬ-ᵡᵸᶛ-ᶿₐ-ₔⵯ々〱-〵〻ゝゞー-ヾꀕꜗ-ꜚｰﾞﾟa-zªµºß-öø-ÿāăąćĉċčďđēĕėęěĝğġģĥħĩīĭįıĳĵķĸĺļľŀłńņňŉŋōŏőœŕŗřśŝşšţťŧũūŭůűųŵŷźżž-ƀƃƅƈƌƍƒƕƙ-ƛƞơƣƥƨƪƫƭưƴƶƹƺƽ-ƿǆǉǌǎǐǒǔǖǘǚǜǝǟǡǣǥǧǩǫǭǯǰǳǵǹǻǽǿȁȃȅȇȉȋȍȏȑȓȕȗșțȝȟȡȣȥȧȩȫȭȯȱȳ-ȹȼȿɀɂɇɉɋɍɏ-ʓʕ-ʯͻ-ͽΐά-ώϐϑϕ-ϗϙϛϝϟϡϣϥϧϩϫϭϯ-ϳϵϸϻϼа-џѡѣѥѧѩѫѭѯѱѳѵѷѹѻѽѿҁҋҍҏґғҕҗҙқҝҟҡңҥҧҩҫҭүұҳҵҷҹһҽҿӂӄӆӈӊӌӎӏӑӓӕӗәӛӝӟӡӣӥӧөӫӭӯӱӳӵӷӹӻӽӿԁԃԅԇԉԋԍԏԑԓա-ևᴀ-ᴫᵢ-ᵷᵹ-ᶚḁḃḅḇḉḋḍḏḑḓḕḗḙḛḝḟḡḣḥḧḩḫḭḯḱḳḵḷḹḻḽḿṁṃṅṇṉṋṍṏṑṓṕṗṙṛṝṟṡṣṥṧṩṫṭṯṱṳṵṷṹṻṽṿẁẃẅẇẉẋẍẏẑẓẕ-ẛạảấầẩẫậắằẳẵặẹẻẽếềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹἀ-ἇἐ-ἕἠ-ἧἰ-ἷὀ-ὅὐ-ὗὠ-ὧὰ-ώᾀ-ᾇᾐ-ᾗᾠ-ᾧᾰ-ᾴᾶᾷιῂ-ῄῆῇῐ-ΐῖῗῠ-ῧῲ-ῴῶῷⁱⁿℊℎℏℓℯℴℹℼℽⅆ-ⅉⅎↄⰰ-ⱞⱡⱥⱦⱨⱪⱬⱴⱶⱷⲁⲃⲅⲇⲉⲋⲍⲏⲑⲓⲕⲗⲙⲛⲝⲟⲡⲣⲥⲧⲩⲫⲭⲯⲱⲳⲵⲷⲹⲻⲽⲿⳁⳃⳅⳇⳉⳋⳍⳏⳑⳓⳕⳗⳙⳛⳝⳟⳡⳣⳤⴀ-ⴥﬀ-ﬆﬓ-ﬗａ-ｚ ]/;
  out$.merge = merge = merge = function(){
    var args, r;
    args = slice$.call(arguments);
    r = function(rval, hval){
      return import$(rval, hval);
    };
    return args.reduce(r, {});
  };
  out$.title2slug = title2slug = function(title, id){
    title = title.toLowerCase();
    title = title.replace(unicodeNonLetters, '');
    title = title.replace(/\s+/g, '-');
    title = title.slice(0, 30);
    if (id) {
      title = title.concat("-" + id);
    }
    return title;
  };
  topForums = function(limit, fields){
    var sql;
    fields == null && (fields = '*');
    sql = "SELECT " + fields + " FROM forums\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY created DESC, id ASC\nLIMIT $2";
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  subForums = function(id, fields){
    var sql;
    fields == null && (fields = '*');
    sql = "SELECT " + fields + "\nFROM forums\nWHERE parent_id=$1\nORDER BY created DESC, id DESC";
    return plv8.execute(sql, [id]);
  };
  out$.topPosts = topPosts = function(sort, limit, fields){
    var sortExpr, sql;
    fields == null && (fields = 'p.*');
    sortExpr = (function(){
      switch (sort) {
      case 'recent':
        return 'p.created DESC, id ASC';
      case 'popular':
        return '(SELECT (SUM(views) + COUNT(*)*2) FROM posts WHERE thread_id=p.thread_id GROUP BY thread_id) DESC';
      default:
        throw new Error("invalid sort for top-posts: " + sort);
      }
    }());
    sql = "SELECT\n  " + fields + ",\n  MIN(a.name) user_name,\n  MIN(u.photo) user_photo,\n  COUNT(p.id) post_count\nFROM aliases a\nJOIN posts p ON a.user_id=p.user_id\nJOIN users u ON u.id=a.user_id\nJOIN forums f ON f.id = p.forum_id\nJOIN sites s ON s.id=f.site_id\nLEFT JOIN posts p2 ON p2.thread_id=p.id\nLEFT JOIN moderations m ON m.post_id=p.id\nWHERE a.site_id=s.id\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\n  AND m.post_id IS NULL\nGROUP BY p.id\nORDER BY " + sortExpr + "\nLIMIT $2";
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  subPosts = function(siteId, postId, limit, offset){
    var sql;
    sql = 'SELECT p.*, a.name user_name, u.photo user_photo\nFROM posts p\nJOIN aliases a ON a.user_id=p.user_id\nJOIN users u ON u.id=a.user_id\nLEFT JOIN moderations m ON m.post_id=p.id\nWHERE a.site_id=$1\n  AND p.parent_id=$2\n  AND m.post_id IS NULL\nORDER BY created ASC, id ASC\nLIMIT $3 OFFSET $4';
    return plv8.execute(sql, [siteId, postId, limit, offset]);
  };
  out$.subPostsTree = subPostsTree = subPostsTree = function(siteId, parentId, limit, offset, depth){
    var sp, i$, len$, p, results$ = [];
    depth == null && (depth = 3);
    sp = subPosts(siteId, parentId, limit, offset);
    if (depth <= 0) {
      for (i$ = 0, len$ = sp.length; i$ < len$; ++i$) {
        p = sp[i$];
        results$.push(merge(p, {
          posts: [],
          morePosts: !!subPosts(siteId, p.id, limit, 0).length
        }));
      }
      return results$;
    } else {
      for (i$ = 0, len$ = sp.length; i$ < len$; ++i$) {
        p = sp[i$];
        results$.push(merge(p, {
          posts: subPostsTree(siteId, p.id, limit, 0, depth - 1)
        }));
      }
      return results$;
    }
  };
  postsTree = function(siteId, forumId, topPosts){
    var i$, len$, p, results$ = [];
    for (i$ = 0, len$ = topPosts.length; i$ < len$; ++i$) {
      p = topPosts[i$];
      results$.push(merge(p, {
        posts: subPostsTree(siteId, p.id, 10, 0)
      }));
    }
    return results$;
  };
  decorateMenu = function(f){
    var sf;
    return merge(f, {
      forums: (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = subForums(f.id, 'id,title,slug,uri,description,media_url')).length; i$ < len$; ++i$) {
          sf = ref$[i$];
          results$.push(decorateMenu(sf));
        }
        return results$;
      }())
    });
  };
  decorateForum = function(f, topPostsFun){
    var sf;
    return merge(f, {
      posts: postsTree(f.site_id, f.id, topPostsFun(f.id)),
      forums: (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = subForums(f.id)).length; i$ < len$; ++i$) {
          sf = ref$[i$];
          results$.push(decorateForum(sf, topPostsFun));
        }
        return results$;
      }())
    });
  };
  out$.doc = doc = function(){
    var res;
    if (res = plv8.execute('SELECT json FROM docs WHERE site_id=$1 AND type=$2 AND key=$3', arguments)[0]) {
      return JSON.parse(res.json);
    } else {
      return null;
    }
  };
  out$.putDoc = putDoc = function(){
    var args, insertSql, updateSql, e;
    args = slice$.call(arguments);
    insertSql = 'INSERT INTO docs (site_id, type, key, json) VALUES ($1, $2, $3, $4)';
    updateSql = 'UPDATE docs SET json=$4 WHERE site_id=$1::bigint AND type=$2::varchar(64) AND key=$3::varchar(64)';
    if (args[3]) {
      args[3] = JSON.stringify(args[3]);
    }
    try {
      plv8.subtransaction(function(){
        return plv8.execute(insertSql, args);
      });
    } catch (e$) {
      e = e$;
      plv8.execute(updateSql, args);
    }
    return true;
  };
  forumTree = function(forumId, topPostsFun){
    var sql, f;
    sql = 'SELECT id,site_id,parent_id,title,slug,description,media_url,classes FROM forums WHERE id=$1 LIMIT 1';
    if (f = plv8.execute(sql, [forumId])[0]) {
      return decorateForum(f, topPostsFun);
    }
  };
  forumsTree = function(siteId, topPostsFun, topForumsFun){
    var i$, ref$, len$, f, results$ = [];
    for (i$ = 0, len$ = (ref$ = topForumsFun(siteId)).length; i$ < len$; ++i$) {
      f = ref$[i$];
      results$.push(decorateForum(f, topPostsFun));
    }
    return results$;
  };
  out$.uriForForum = uriForForum = function(forumId){
    var sql, ref$, parent_id, slug;
    sql = 'SELECT parent_id, slug FROM forums WHERE id=$1';
    ref$ = plv8.execute(sql, [forumId])[0], parent_id = ref$.parent_id, slug = ref$.slug;
    if (parent_id) {
      return this.uriForForum(parent_id) + '/' + slug;
    } else {
      return '/' + slug;
    }
  };
  out$.uriForPost = uriForPost = function(postId, firstSlug){
    var sql, ref$, forum_id, parent_id, slug;
    firstSlug == null && (firstSlug = null);
    sql = 'SELECT forum_id, parent_id, slug FROM posts WHERE id=$1';
    ref$ = plv8.execute(sql, [postId])[0], forum_id = ref$.forum_id, parent_id = ref$.parent_id, slug = ref$.slug;
    if (parent_id) {
      if (firstSlug) {
        return this.uriForPost(parent_id, firstSlug);
      } else {
        return this.uriForPost(parent_id, slug);
      }
    } else {
      if (firstSlug) {
        return this.uriForForum(forum_id) + '/t/' + slug + '/' + firstSlug;
      } else {
        return this.uriForForum(forum_id) + '/t/' + slug;
      }
    }
  };
  out$.menu = menu = function(siteId){
    var topMenuFun, i$, ref$, len$, f, results$ = [];
    topMenuFun = topForums(null, 'id,title,slug,uri,description,media_url');
    for (i$ = 0, len$ = (ref$ = topMenuFun(siteId)).length; i$ < len$; ++i$) {
      f = ref$[i$];
      results$.push(decorateMenu(f, topMenuFun));
    }
    return results$;
  };
  out$.homepageForums = homepageForums = function(siteId, sort){
    sort == null && (sort = 'recent');
    return forumsTree(siteId, topPosts(sort, 10), topForums());
  };
  out$.forums = forums = function(forumId, sort){
    var ft;
    ft = forumTree(forumId, topPosts(sort));
    if (ft) {
      return [ft];
    } else {
      return [];
    }
  };
  out$.topThreads = topThreads = function(forumId, sort){
    return topPosts(sort)(forumId);
  };
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
