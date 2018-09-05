<template>
  <div id="app">
    <div class="container">
      <div class="main">
        <div class="header">
          <input v-model="search" class="input-search" placeholder="🔍请输入搜索内容"/>
          <button @click="onSearch">搜索</button>
          <button @click="onRest">重置</button>
          <button @click="loadLog">刷新</button>
        </div>
        <div class="log-container">
          <v-table
            class="log-table"
            :width="700"
            :height="600"
            :columns="columns"
            :column-cell-class-name="columnCellClass"
            :table-data="tableData"
            :show-vertical-border="false"
            row-hover-color="#eee"
            row-click-color="#edf7ff"
            :row-click="onClick"
            :row-height="25"
          ></v-table>
          </div>
      </div>
      <div class="right-panel">
        <Detail :request="selectedRequest"></Detail>
      </div>
    </div>

  </div>
</template>

<script>
import Detail from './Detail.vue'

export default {
  name: 'app',
  components: {Detail},
  data () {
    return {
      search: '',
      logs: [],
      tableData: [],
      selectedRequest: {},
      columns: [
        {field: 'url', title:'Domain', titleAlign: 'left',columnAlign:'left'},
        {field: 'method', title: 'Method', width: 60, titleAlign: 'left',columnAlign:'left'},
        {field: 'status', title: 'Status', width: 60, titleAlign: 'left',columnAlign:'left'},
        {field: 'duration', title: 'Duration', width:60, titleAlign: 'left',columnAlign:'left'},
        {field: '', title: '', width:20, titleAlign: 'left', columnAlign:'right'},
      ]
    }
  },
  created() {
    this.loadLog();
  },
  methods: {
    loadLog () {
      fetch('/log')
        .then(resp => resp.json())
        .then(resp => {
          this.logs = resp;
          this.tableData = resp.slice(0);
        })
    },
    onSearch() {
      if (this.search.length > 0) {
        var results = new Array();
        for (var i in this.logs) {
          var log = this.logs[i];
          console.log(log.url);
          if (log.url.indexOf(this.search) > 0) {
            results.push(log);
          }
        }
        this.tableData = results;
      }
    },
    onRest() {
      this.search = '';
      this.tableData = this.logs.slice(0);
    },
    onClick(rowIndex, rowData, column) {
//      console.log(rowData);
      this.selectedRequest = rowData;
    },
    columnCellClass(rowIndex,columnName,rowData) {
      if (columnName === 'duration') {
        return 'cell-duration';
      }
    }
  }
}
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    color: #2c3e50;
    border: 1px solid #999999;
    width: 1024px;
    height: 640px;
    margin-top: 20px;
    margin-left: auto;
    margin-right: auto;
  }

  .container {
    display: flex;
    flex-direction: row;
  }
  .right-panel {
    width: 323px;
    height: 640px;
  }
  .main {
    height: 640px;
    width: 701px;
    display: flex;
    flex-direction: column;
    border-right: 1px solid #999999;
  }
  .header {
    background-color: #eeeeee;
    width: 100%;
    height: 38px;
    display: flex;
    flex-direction: row;
  }
  .log-container {
    width: 100%;
    height: 600px;
    overflow:auto;
    text-align: center;
  }
  .log-table {
    width: 100%;
    height: 100%;
  }
  .log-detail {
    width: 100%;
    height: 100%;
  }
  .v-table-class	 {
    font-size: 13px;
  }
  .cell-duration{
    margin-right: 40px;
    padding-right: 40px;
  }
  .input-search {
    margin: 5px;
    width: 500px;
    padding-left: 5px;
  }
  button {
    margin: 5px;
    border-radius: 4px;
    padding-left: 10px;
    padding-right: 10px;
  }
</style>
