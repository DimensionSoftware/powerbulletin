require! \./Component.ls

{templates} = require \../build/component-jade.js

function calculate {page, step, qty}
  page-qty = qty / step
  {
    page-qty
    active-pages: [1 to page-qty]
  }

module.exports =
  class Paginator extends Component
    default-locals =
      page: 1
      step: 8
      qty: 0

    (opts, ...rest) ->
      opts ||= {}
      locals = {} <<< default-locals <<< opts.locals
      locals <<< calculate(locals)
      opts <<< {locals}

      super opts, ...rest
    component-name: \Paginator
    template: templates.Paginator

# REPL EXAMPLE:
# require! \./component/Paginator; p = new Paginator {locals: {qty: 500}}; p.html!
# ->
# '<div class="Paginator"><a href="#">1</a><a href="#">2</a><a href="#">3</a><a href="#">4</a><a href="#">5</a><a href="#">6</a><a href="#">7</a><a href="#">8</a><a href="#">9</a><a href="#">10</a><a href="#">11</a><a href="#">12</a><a href="#">13</a><a href="#">14</a><a href="#">15</a><a href="#">16</a><a href="#">17</a><a href="#">18</a><a href="#">19</a><a href="#">20</a><a href="#">21</a><a href="#">22</a><a href="#">23</a><a href="#">24</a><a href="#">25</a><a href="#">26</a><a href="#">27</a><a href="#">28</a><a href="#">29</a><a href="#">30</a><a href="#">31</a><a href="#">32</a><a href="#">33</a><a href="#">34</a><a href="#">35</a><a href="#">36</a><a href="#">37</a><a href="#">38</a><a href="#">39</a><a href="#">40</a><a href="#">41</a><a href="#">42</a><a href="#">43</a><a href="#">44</a><a href="#">45</a><a href="#">46</a><a href="#">47</a><a href="#">48</a><a href="#">49</a><a href="#">50</a><a href="#">51</a><a href="#">52</a><a href="#">53</a><a href="#">54</a><a href="#">55</a><a href="#">56</a><a href="#">57</a><a href="#">58</a><a href="#">59</a><a href="#">60</a><a href="#">61</a><a href="#">62</a></div>'
