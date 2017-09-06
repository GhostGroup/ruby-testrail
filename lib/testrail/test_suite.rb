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

require 'testrail/test_run'
require 'testrail/test_section'
require 'testrail/test_case'

module TestRail

  class TestSuite

    def initialize(project_id:, suite_id:, testrail_client:, custom_fields: nil)
      @project_id = project_id
      @suite_id = suite_id
      @testrail_client = testrail_client
      sections = testrail_client.get_sections(project_id: project_id, suite_id: suite_id)
                                .map { |s| new_test_section(s) }
      @sections_by_name = Hash[sections.map { |s| [s.name, s] }]
      @sections_by_id = Hash[sections.map { |s| [s.id, s] }]
      @custom_fields = custom_fields
      @test_cases = Hash[testrail_client.get_test_cases(project_id: project_id, suite_id: suite_id)
                                        .lazy
                                        .map { |t| new_test_case(t) }
                                        .map { |t| [test_case_key(t.section.id, t.name), t] }
                    .to_a]
    end

    def start_test_run
      run = @testrail_client.start_test_run(project_id: @project_id, suite_id: @suite_id)
      TestRun.new(suite: self, id: run['id'])
    end

    def submit_test_results(run_id:, results:)
      @testrail_client.submit_test_results(run_id: run_id, results: results.map(&:to_hash))
    end

    def close_test_run(run_id)
      @testrail_client.close_test_run(run_id)
    end

    def get_or_create_section(section_name)
      @sections_by_name[section_name] || create_section(section_name)
    end

    def get_or_create_test_case(section_id:, name:)
      @test_cases[test_case_key(section_id, name)] || create_test_case(section_id: section_id, name: name)
    end

    def create_section(section_name)
      section = new_test_section(@testrail_client.create_section(
                                   project_id: @project_id,
                                   suite_id: @suite_id,
                                   section_name: section_name))
      @sections_by_name[section_name] = section
      @sections_by_id[section.id] = section
    end

    def create_test_case(section_id:, name:)
      case_data = @testrail_client.create_test_case(
        section_id: section_id,
        name: name,
        custom_fields: @custom_fields
      )
      test_case = new_test_case(case_data)
      @test_cases[test_case_key(test_case.section.id, test_case.name)] = test_case
    end

    private

    def test_case_key(section_id, name)
      { s: section_id, n: name }
    end

    def new_test_section(section)
      TestSection.new(
        id: section['id'],
        name: section['name'],
        test_suite: self)
    end

    def new_test_case(test_case)
      TestCase.new(
        id: test_case['id'],
        name: test_case['title'],
        section: @sections_by_id[test_case['section_id']],
        testrail_client: @testrail_client)
    end

  end

end
