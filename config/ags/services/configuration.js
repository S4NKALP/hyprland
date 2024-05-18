// @ts-nocheck
import { Variable as Var } from "resource:///com/github/Aylur/ags/variable.js";
import { deepMerge } from "../functions/utils.js";
import { replacePlaceholders, reverseReplace } from "../functions/utils.js";
export const configPath = App.configDir + "/config.json";

class Conf extends Var {
  static {
    Service.register(this);
  }

  constructor(key, callback = () => null, replaceData = {}) {
    super("");
    const config = JSON.parse(Utils.readFile(configPath) || "{}");
    this.key = key;
    this.replaceData = replaceData;
    this.setValue(
      replacePlaceholders(
        this.key.includes(".")
          ? this.#accessNestedJson(config, this.key)
          : config[this.key],
        this.replaceData,
      ),
    );
    this.connect("changed", callback);
  }

  key = "";
  replaceData = {};

  #accessNestedJson(data, keys) {
    const keysArray = keys.split(".");
    let result = data;
    for (const key of keysArray) {
      if (key in result) {
        result = result[key];
      } else {
        return null;
      }
    }
    return result;
  }

  #createNestedJson(key, newvalue) {
    const keysarray = key.split(".");
    let result = {};
    let temp = result;
    for (let i = 0; i < keysarray.length - 1; i++) {
      temp[keysarray[i]] = {};
      temp = temp[keysarray[i]];
    }
    temp[keysarray[keysarray.length - 1]] = newvalue;
    return result;
  }

  updateValue(value) {
    super.setValue(value);
    let json = {};
    if (!this.key.includes(".")) {
      json[this.key] = value;
    } else {
      json = this.#createNestedJson(
        this.key,
        reverseReplace(value, this.replaceData),
      );
    }
    this.#setConfig(json);
  }

  #setConfig(value) {
    const configs = JSON.parse(Utils.readFile(configPath) || "{}");

    const updatedConfig = deepMerge(configs, value);
    const configString = JSON.stringify(updatedConfig, null, 2); // this.#betterStringify(updatedConfig);
    Utils.writeFile(configString, configPath);
  }
}

export default (keyz, call, replace) => new Conf(keyz, call, replace);
