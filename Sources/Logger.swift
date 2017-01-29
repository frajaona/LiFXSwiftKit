/*
 * Copyright (C) 2017 Fred Rajaona
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import Evergreen


class Log {
    
    fileprivate static let logger: Evergreen.Logger = Evergreen.getLogger("LiFX")
    
    static func verbose(_ message: String) {
        logger.verbose(message)
    }
    
    static func debug(_ message: String) {
        logger.debug(message)
    }
    
    static func info(_ message: String) {
        logger.info(message)
    }
    
    static func warning(_ message: String) {
        logger.warning(message)
    }
    
    static func error(_ message: String) {
        logger.error(message)
    }
    
}
