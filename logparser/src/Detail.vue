<template>
  <div id="detail">
    <div class="label"> Full URL </div>
    <div class="content">
      {{ request.url }}
    </div>

    <div class="label"> cURL </div>
    <div class="content"> {{ curlCommand }} </div>

    <div class="label"> Request Header </div>
    <div class="headers">
      <ul v-for="header in request.requestHeaders">
        <li> <strong>{{ header.key }} :</strong> {{ header.value }} </li>
      </ul>
    </div>

    <div class="label"> Request Data </div>
    <div class="content"> {{ requestData }} </div>

    <div class="label"> Response Header </div>
    <div class="headers">
      <ul v-for="header in request.responseHeaders">
        <li> <strong>{{ header.key }} :</strong> {{ header.value }} </li>
      </ul>
    </div>

    <div class="label"> Response Data </div>
    <div class="content"> {{ responseData }} </div>

  </div>
</template>

<script>
  export default {
    name: 'Detail',
    props : {
      request: {
        type: Object,
        required: false
      }
    },
    computed: {
      requestData: function () {
        if (this.request.requestData == null) {
          return '';
        }
        else {
          return window.atob(this.request.requestData);
        }
      },
      responseData: function () {
        if (this.request.responseData == null) {
          return '';
        }
        else {
          return window.atob(this.request.responseData);
        }
      },
      curlCommand: function () {
        if (typeof(this.request.url) == "undefined") {
          return ''
        }
        var cmd = 'curl ' + '"' + this.request.url + '"' + ' -v ';
        for (var i in this.request.requestHeaders) {
          var header = this.request.requestHeaders[i];
          cmd = cmd + '-H ' + '"' + header.key + ':' + header.value + '" '
        }
        if (this.requestData.length > 0) {
            cmd = cmd + '-d "' + this.requestData + '"';
        }
        return cmd;
      }
    },
    methods: {
      parseUrl (url) {
        var param = new Array()
        var items;
        if (url == "") {
          return param;
        };
        var query = url
        var list = query.split('&');
        for(var i = 0; i < list.length; i++) {
          items = list[i].split('=');
          param.push({'key' : items[0], 'value' : items[1]});
        };
        return param;
      }
    }
  };
</script>

<style>

  #detail {
    overflow: auto;
    height: 100%;
    padding-right: 3px;
    word-break:break-all;
    width: 324px;
  }

  .label {
    padding: 4px;
    padding-left: 10px;
    font-size: 14px;
    background-color: #eeeeee;
    border-bottom: 1px solid #999999;
  }

  .content {
    padding: 0 10px;
    font-size: 13px;
  }

  .headers {

  }

  ul {
    list-style-type: none;
    padding: 0;
    margin: 0;
    margin-left: 10px;
    margin-right: 10px;
  }

  li {
    font-size: 13px;
    display: inline-block;
    margin: 0;
    padding: 0;
  }

</style>
