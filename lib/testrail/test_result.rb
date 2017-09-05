# Copyright 2016 Findly Inc. NZ
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module TestRail

  class TestResult

    STATUS_SUCCESS = 1
    STATUS_ERROR = 5

    attr_reader :comment
    attr_reader :success
    alias success? success

    def initialize(test_case:, success:, comment:)
      @test_case = test_case
      @success = success
      @comment = comment
    end

    def status_id
      success? ? STATUS_SUCCESS : STATUS_ERROR
    end

    def to_hash
      {
        'case_id' => @test_case.id,
        'status_id' => status_id,
        'comment' => comment
      }
    end

  end

end
