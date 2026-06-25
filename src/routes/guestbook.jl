function _gb_js()
    raw"""
(function(){
  var SB = (window.DEMO_SB && window.DEMO_SB.key) ? window.DEMO_SB : null;
  var form=document.getElementById('gb-form'), list=document.getElementById('gb-list');
  var nameI=document.getElementById('gb-name'), msgI=document.getElementById('gb-msg');
  var mode=document.getElementById('gb-mode');
  if(mode) mode.textContent = SB ? 'live database' : 'your browser (demo)';
  function esc(s){return String(s==null?'':s).replace(/[&<>\"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c];});}
  function ago(t){try{var d=(Date.now()-new Date(t).getTime())/1000;if(d<60)return'just now';if(d<3600)return Math.floor(d/60)+'m ago';if(d<86400)return Math.floor(d/3600)+'h ago';return Math.floor(d/86400)+'d ago';}catch(e){return''}}
  function row(it){return '<div class="border-b border-base-200 last:border-0 py-3"><div class="flex items-center justify-between gap-3"><span class="font-semibold text-sm text-base-content">'+esc(it.name||'anon')+'</span><span class="text-xs text-base-content/40">'+ago(it.created_at)+'</span></div><p class="text-sm text-base-content/80 mt-0.5">'+esc(it.message)+'</p></div>';}
  function render(items){items=items||[];list.innerHTML=items.length?items.map(row).join(''):'<p class="text-sm text-base-content/50 py-6 text-center">No messages yet — be the first.</p>';}
  function lsGet(){try{return JSON.parse(localStorage.getItem('gb')||'[]')}catch(e){return[]}}
  function lsAdd(it){var a=lsGet();a.unshift(it);a=a.slice(0,50);localStorage.setItem('gb',JSON.stringify(a));return a;}
  async function load(){
    if(SB){try{var r=await fetch(SB.url+'/rest/v1/demo_guestbook?select=name,message,created_at&order=created_at.desc&limit=50',{headers:{apikey:SB.key,authorization:'Bearer '+SB.key}});if(r.ok){render(await r.json());return;}}catch(e){}}
    render(lsGet());
  }
  form.addEventListener('submit',async function(e){
    e.preventDefault();
    var name=(nameI.value||'anon').slice(0,40), message=(msgI.value||'').slice(0,280);
    if(!message.trim())return; msgI.value='';
    if(SB){try{await fetch(SB.url+'/rest/v1/demo_guestbook',{method:'POST',headers:{apikey:SB.key,authorization:'Bearer '+SB.key,'content-type':'application/json',prefer:'return=minimal'},body:JSON.stringify({name:name,message:message})});load();return;}catch(e){}}
    render(lsAdd({name:name,message:message,created_at:new Date().toISOString()}));
  });
  load();
})();
"""
end

function Guestbook()
    Div(:class => "space-y-8",
        RawHtml("""<script>window.DEMO_SB = { url: "", key: "" };</script>"""),
        Div(:class => "max-w-2xl",
            Span(:class => "badge badge-accent badge-outline mb-3", "real persistence"),
            H1(:class => "a-display text-3xl sm:text-4xl font-bold text-base-content", "A database, from a static site."),
            P(:class => "mt-3 text-base-content/70 leading-relaxed",
                "Leave a message — it saves to a real database the moment you hit send. The browser talks to it directly, secured by row-level security. There is no server in between. Currently saving to: ",
                RawHtml("""<b id="gb-mode" class="text-base-content">your browser (demo)</b>"""), ".")),
        Div(:class => "grid md:grid-cols-2 gap-6",
            Div(:class => "a-card bg-base-100 rounded-box p-6",
                RawHtml("""<form id="gb-form" class="space-y-3">
                  <input id="gb-name" class="input input-bordered w-full" placeholder="Your name" maxlength="40">
                  <textarea id="gb-msg" class="textarea textarea-bordered w-full" rows="3" placeholder="Say hi…" maxlength="280"></textarea>
                  <button class="btn btn-primary w-full" type="submit">Sign the guestbook</button>
                </form>""")),
            Div(:class => "a-card bg-base-100 rounded-box p-6",
                H3(:class => "a-display font-semibold text-base-content mb-1", "Messages"),
                RawHtml("""<div id="gb-list" class="max-h-72 overflow-y-auto"></div>"""))),
        RawHtml("<script>" * _gb_js() * "</script>"))
end
Guestbook
