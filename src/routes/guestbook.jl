function _gb_js()
    raw"""
(function(){
  var SB = (window.DEMO_SB && window.DEMO_SB.key && window.DEMO_SB.url) ? window.DEMO_SB : null;
  var form=document.getElementById('gb-form'), list=document.getElementById('gb-list');
  var nameI=document.getElementById('gb-name'), msgI=document.getElementById('gb-msg');
  var mode=document.getElementById('gb-mode'), note=document.getElementById('gb-note');
  if(mode) mode.textContent = SB ? 'live database' : 'your browser (demo)';
  // per-browser delete token (never identifies you; the server stores only its hash)
  var TOK = (function(){try{var t=localStorage.getItem('gb-token');if(!t){t=(crypto.randomUUID?crypto.randomUUID():String(Math.random())+Date.now());localStorage.setItem('gb-token',t);}return t;}catch(e){return''}})();
  function mineGet(){try{return JSON.parse(localStorage.getItem('gb-mine')||'[]')}catch(e){return[]}}
  function mineAdd(id){var a=mineGet();a.unshift(id);a=a.slice(0,200);localStorage.setItem('gb-mine',JSON.stringify(a));}
  function mineDel(id){localStorage.setItem('gb-mine',JSON.stringify(mineGet().filter(function(x){return x!=id})));}
  var MINE = {}; mineGet().forEach(function(id){MINE[id]=1;});
  function esc(s){return String(s==null?'':s).replace(/[&<>\"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c];});}
  function ago(t){try{var d=(Date.now()-new Date(t).getTime())/1000;if(d<60)return'just now';if(d<3600)return Math.floor(d/60)+'m ago';if(d<86400)return Math.floor(d/3600)+'h ago';return Math.floor(d/86400)+'d ago';}catch(e){return''}}
  function row(it){
    var del = (SB && it.id!=null && MINE[it.id]) ? '<button class="gb-del text-xs text-error/70 hover:text-error" data-id="'+esc(it.id)+'" title="Delete your message">delete</button>' : '';
    return '<div class="border-b border-base-200 last:border-0 py-3"><div class="flex items-center justify-between gap-3"><span class="font-semibold text-sm text-base-content">'+esc(it.name||'anon')+'</span><span class="flex items-center gap-2 text-xs text-base-content/40">'+ago(it.created_at)+del+'</span></div><p class="text-sm text-base-content/80 mt-0.5 break-words">'+esc(it.message)+'</p></div>';
  }
  function render(items){items=items||[];list.innerHTML=items.length?items.map(row).join(''):'<p class="text-sm text-base-content/50 py-6 text-center">No messages yet — be the first.</p>';
    list.querySelectorAll('.gb-del').forEach(function(b){b.addEventListener('click',function(){del(b.getAttribute('data-id'));});});}
  function setNote(t){if(note){note.textContent=t||'';}}
  function lsGet(){try{return JSON.parse(localStorage.getItem('gb')||'[]')}catch(e){return[]}}
  function lsAdd(it){var a=lsGet();a.unshift(it);a=a.slice(0,50);localStorage.setItem('gb',JSON.stringify(a));return a;}
  async function load(){
    if(SB){try{var r=await fetch(SB.url+'/rest/v1/demo_guestbook?select=id,name,message,created_at&order=created_at.desc&limit=50',{headers:{apikey:SB.key,authorization:'Bearer '+SB.key}});if(r.ok){render(await r.json());return;}}catch(e){}}
    render(lsGet());
  }
  async function del(id){
    if(SB){try{
      var r=await fetch(SB.url+'/rest/v1/rpc/delete_guestbook',{method:'POST',headers:{apikey:SB.key,authorization:'Bearer '+SB.key,'content-type':'application/json'},body:JSON.stringify({p_id:Number(id),p_token:TOK})});
      if(r.ok){mineDel(id);delete MINE[id];load();}
    }catch(e){}return;}
    render(lsGet().filter(function(x){return x.id!=id}));
  }
  form.addEventListener('submit',async function(e){
    e.preventDefault();
    var name=(nameI.value||'anon').slice(0,40), message=(msgI.value||'').slice(0,280);
    if(!message.trim())return; setNote('');
    if(SB){try{
      var r=await fetch(SB.url+'/rest/v1/rpc/add_guestbook',{method:'POST',headers:{apikey:SB.key,authorization:'Bearer '+SB.key,'content-type':'application/json',prefer:'return=representation'},body:JSON.stringify({p_name:name,p_message:message,p_token:TOK})});
      if(r.ok){var id=await r.json();if(id!=null){mineAdd(id);MINE[id]=1;}msgI.value='';load();return;}
      var err=await r.json().catch(function(){return{}}); setNote(err.message||'Could not post — please try again.'); return;
    }catch(e){setNote('Network error — please try again.');return;}}
    msgI.value='';
    render(lsAdd({id:'ls-'+Date.now(),name:name,message:message,created_at:new Date().toISOString()}));
  });
  load();
})();
"""
end

function Guestbook()
    Div(:class => "space-y-8",
        # PUBLIC anon key only — it is safe to expose: row-level security + the
        # add_guestbook/delete_guestbook functions are the protection (see db.sql).
        # NEVER put the service_role key here. Leave blank to fall back to the
        # in-browser demo. Fill both to go live.
        RawHtml("""<script>window.DEMO_SB = {
  url: "",  /* e.g. https://YOUR-PROJECT.supabase.co */
  key: ""   /* the PUBLIC anon key (starts with eyJ...) — never the service_role key */
};</script>"""),
        Div(:class => "max-w-2xl",
            Span(:class => "badge badge-accent badge-outline mb-3", "real persistence"),
            H1(:class => "a-display text-3xl sm:text-4xl font-bold text-base-content", "A database, from a static site."),
            P(:class => "mt-3 text-base-content/70 leading-relaxed",
                "Leave a message — it saves to a real database the moment you hit send. The browser talks to it directly, secured by row-level security. There is no server in between. Currently saving to: ",
                RawHtml("""<b id="gb-mode" class="text-base-content">your browser (demo)</b>"""), "."),
            P(:class => "mt-2 text-xs text-base-content/50",
                "Messages are capped at 280 characters and rate-limited. You can delete anything you posted from this browser.")),
        Div(:class => "grid md:grid-cols-2 gap-6",
            Div(:class => "a-card bg-base-100 rounded-box p-6",
                RawHtml("""<form id="gb-form" class="space-y-3">
                  <input id="gb-name" class="input input-bordered w-full" placeholder="Your name" maxlength="40">
                  <textarea id="gb-msg" class="textarea textarea-bordered w-full" rows="3" placeholder="Say hi…" maxlength="280"></textarea>
                  <button class="btn btn-primary w-full" type="submit">Sign the guestbook</button>
                  <p id="gb-note" class="text-xs text-error min-h-4" role="alert"></p>
                </form>""")),
            Div(:class => "a-card bg-base-100 rounded-box p-6",
                H3(:class => "a-display font-semibold text-base-content mb-1", "Messages"),
                RawHtml("""<div id="gb-list" class="max-h-72 overflow-y-auto"></div>"""))),
        RawHtml("""<details class="text-sm text-base-content/60 max-w-2xl">
          <summary class="cursor-pointer hover:text-base-content">How is a public database safe from the browser?</summary>
          <div class="mt-2 space-y-1.5 text-base-content/70">
            <p>The key in this page is Supabase's <b>public anon key</b> — it's meant to be shared and grants nothing on its own. Safety comes from the database, not from hiding the key (the <code>service_role</code> key is never shipped to the browser).</p>
            <p>The browser can't write to the table directly. Posts and deletes go through locked-down database functions that cap message length, rate-limit per IP, bound total rows, and let you delete only your own messages. Reads expose nothing but name, message, and time.</p>
            <p>Want the exact recipe? It's in <a class="link link-primary" href="https://github.com/Dale-Black/snapshot-app-demo/blob/main/db.sql" target="_blank">db.sql</a> and the <a class="link link-primary" href="https://github.com/Dale-Black/snapshot-app-demo#readme" target="_blank">README</a>.</p>
          </div>
        </details>"""),
        RawHtml("<script>" * _gb_js() * "</script>"))
end
Guestbook
