"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Coin = void 0;
const constants_1 = require("../constants");
const BadRequest_1 = require("./BadRequest");
class Coin {
    denomination;
    constructor(denomination) {
        if (!constants_1.DENOMINATIONS.includes(denomination)) {
            throw new BadRequest_1.BadRequest(`Invalid coin denomination. Allowed denominations are: ${constants_1.DENOMINATIONS.join(', ')}`);
        }
        this.denomination = denomination;
    }
    getDenomination() {
        return this.denomination;
    }
}
exports.Coin = Coin;
//# sourceMappingURL=Coin.js.map